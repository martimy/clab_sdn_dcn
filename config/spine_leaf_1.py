"""
MIT License

Copyright (c) 2022 Maen Artimy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

from ryu.controller import ofp_event
from ryu.controller.handler import CONFIG_DISPATCHER, MAIN_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.ofproto import ofproto_v1_3
from ryu.lib.packet import packet
from ryu.lib.packet import ethernet
from ryu.lib.packet import ether_types
from ryu.app.ofctl.api import get_datapath
from base_switch import BaseSwitch

# Constants
TABLE0 = 0
MIN_PRIORITY = 0
MID_PRIORITY = 500

# Set idle_time=0 to make flow entries permenant
IDLE_TIME = 30


class Network():
    """
    Network definition
    """
    spines = [11, 12]
    leaves = [21, 22, 23]
    links = {(11, 21): {'port': 1},
             (11, 22): {'port': 2},
             (11, 23): {'port': 3},
             (12, 21): {'port': 1},
             (12, 22): {'port': 2},
             (12, 23): {'port': 3},
             (21, 11): {'port': 1},
             (21, 12): {'port': 2},
             (22, 11): {'port': 1},
             (22, 12): {'port': 2},
             (23, 11): {'port': 1},
             (23, 12): {'port': 2}}


net = Network()


class LearningSwitch1(BaseSwitch):
    """
    A spine-leaf implementation with one table using static network description.
    """

    OFP_VERSIONS = [ofproto_v1_3.OFP_VERSION]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.mac_table = {}
        self.ignore = [ether_types.ETH_TYPE_LLDP, ether_types.ETH_TYPE_IPV6]

    @set_ev_cls(ofp_event.EventOFPSwitchFeatures, CONFIG_DISPATCHER)
    def switch_features_handler(self, event):
        """
        This method is called after the controller configures a switch.
        """

        datapath = event.msg.datapath
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser

        # Delete all exiting flows
        msgs = [self.del_flow(datapath)]

        if datapath.id in net.leaves:
            # Add a table-miss entry for TABLE0 table
            match = parser.OFPMatch()
            actions = [parser.OFPActionOutput(ofproto.OFPP_CONTROLLER,
                                              ofproto.OFPCML_NO_BUFFER)]
            inst = [parser.OFPInstructionActions(ofproto.OFPIT_APPLY_ACTIONS,
                                                 actions)]

            msgs += [self.add_flow(datapath, TABLE0,
                                   MIN_PRIORITY, match, inst)]

        else:
            # Add a table-miss entry for TABLE0 table
            match = parser.OFPMatch()
            inst = []

            msgs += [self.add_flow(datapath, TABLE0,
                                   MIN_PRIORITY, match, inst)]

        # Send all messages to the switch
        self.send_messages(datapath, msgs)

    @set_ev_cls(ofp_event.EventOFPPacketIn, MAIN_DISPATCHER)
    def packet_in_handler(self, event):
        """
        This method is called when a Packet-in message arrives from a swith.
        """

        datapath = event.msg.datapath
        ofproto = datapath.ofproto

        # Get the ingress port
        in_port = event.msg.match['in_port']

        # Get the packet and its header
        pkt = packet.Packet(event.msg.data)
        eth = pkt.get_protocol(ethernet.ethernet)

        # Ignore some packets
        if eth.ethertype in self.ignore:
            return

        # Get the source and distanation MAC addresses
        dst = eth.dst
        src = eth.src

        self.logger.debug("Packet from %i %s %s %i",
                          datapath.id, src, dst, in_port)

        # Set/Update the node information in the MAC table
        src_host = self.mac_table.get(src, {})
        src_host['port'] = in_port
        src_host['dpid'] = datapath.id
        self.mac_table[src] = src_host

        # Get the dst port, if known, or use ALL as dst port
        dst_host = self.mac_table.get(dst)
        out_port = dst_host['port'] if dst_host else ofproto.OFPP_ALL

        if out_port == ofproto.OFPP_ALL:
            # Destination is unknown
            # if packet_out is sent to all switches, the will find their way back to CTRL
            for leaf in net.leaves:
                dpath = get_datapath(self, leaf)
                # Set the in_port to prevent sending pack the packet to the same port
                # in the source switch
                in_port = in_port if datapath.id == leaf else ofproto.OFPP_CONTROLLER
                # Send this packet to the switch to forward it.
                msgs = self.forward_packet(
                    dpath, event.msg.data, in_port, out_port)
                self.send_messages(dpath, msgs)
        else:
            # Destination is known
            if dst_host['dpid'] == datapath.id:
                # Both nodes reside on the same leaf switch

                msgs = self.make_dual_connections(
                    datapath, src, dst, in_port, out_port)

                # Send this packet back to the switch to forward it.
                msgs += self.forward_packet(datapath,
                                            event.msg.data, in_port, out_port)
                self.send_messages(datapath, msgs)
            else:
                # Nodes reside on different leaf switches
                # Install flow entries in two leaf switches and one spine switch

                # Select one spine
                a_num = hash(src_host['dpid'] +
                             dst_host['dpid']) % len(net.spines)
                selected = net.spines[a_num]

                # In the source switch
                upstream_port = net.links[datapath.id, selected]['port']
                msgs = self.make_dual_connections(
                    datapath, src, dst, in_port, upstream_port)
                self.send_messages(datapath, msgs)

                # In the spine switch
                spine_datapath = get_datapath(self, selected)
                dst_datapath = get_datapath(self, dst_host['dpid'])
                spine_ingress_port = net.links[selected, datapath.id]['port']
                spine_egress_port = net.links[selected,
                                              dst_datapath.id]['port']

                msgs = self.make_dual_connections(
                    spine_datapath, src, dst, spine_ingress_port, spine_egress_port)
                self.send_messages(spine_datapath, msgs)

                # In the destination switch
                downstream_port = net.links[dst_datapath.id, selected]['port']
                remote_port = dst_host['port']
                msgs = self.make_dual_connections(
                    dst_datapath, src, dst, downstream_port, remote_port)

                # Send this packet to the destination switch to forward it.
                msgs += self.forward_packet(dst_datapath, event.msg.data,
                                            ofproto.OFPP_CONTROLLER, remote_port)
                self.send_messages(dst_datapath, msgs)

    def forward_packet(self, datapath, data, in_port, out_port):
        """
        Returns OF PACKET_OUT message that forwards a packet to a port
        """

        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser

        actions = [parser.OFPActionOutput(out_port)]
        msgs = [parser.OFPPacketOut(datapath=datapath,
                                    buffer_id=ofproto.OFP_NO_BUFFER, in_port=in_port,
                                    actions=actions, data=data)]
        return msgs

    def make_dual_connections(self, datapath, src, dst, in_port, out_port):
        """
        Return OF MOD messages to allow 2-way packets between two nodes
        """

        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser

        match = parser.OFPMatch(in_port=in_port, eth_src=src, eth_dst=dst)
        actions = [parser.OFPActionOutput(out_port)]
        inst = [parser.OFPInstructionActions(ofproto.OFPIT_APPLY_ACTIONS,
                                             actions)]
        msgs = [self.add_flow(datapath, TABLE0, MID_PRIORITY, match, inst,
                              i_time=IDLE_TIME)]

        match = parser.OFPMatch(in_port=out_port, eth_src=dst, eth_dst=src)
        actions = [parser.OFPActionOutput(in_port)]
        inst = [parser.OFPInstructionActions(ofproto.OFPIT_APPLY_ACTIONS,
                                             actions)]
        msgs += [self.add_flow(datapath, TABLE0, MID_PRIORITY, match, inst,
                               i_time=IDLE_TIME)]
        return msgs

