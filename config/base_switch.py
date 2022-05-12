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

from ryu.base import app_manager
from ryu.ofproto import ofproto_v1_3


class BaseSwitch(app_manager.RyuApp):
    """
    Base Switch Application that includes some utility funtcions.
    """

    OFP_VERSIONS = [ofproto_v1_3.OFP_VERSION]

    def __init__(self, *args, **kwargs):
        super(BaseSwitch, self).__init__(*args, **kwargs)

    @staticmethod
    def add_flow(datapath, table_id, priority, match, inst,
                 h_time=0, i_time=0, cookie=0, flags=0, buffer_id=None):
        """
        Compose a FlowMod message to add a flow entry and return the message.
        """

        parser = datapath.ofproto_parser
        mod = parser.OFPFlowMod(datapath=datapath, table_id=table_id,
                                priority=priority, hard_timeout=h_time,
                                idle_timeout=i_time, cookie=cookie, flags=flags,
                                match=match, instructions=inst)

        return mod

    @staticmethod
    def del_flow(datapath, table_id=-1, match=None, cookie=0, cookie_mask=-1, out_port=0, out_group=0):
        """
        Compose a FlowMod message to delete a flow entry and return the message.
        """

        ofproto = datapath.ofproto
        out_port = out_port or ofproto.OFPP_ANY
        out_group = out_group or ofproto.OFPG_ANY
        table_id = table_id if table_id > -1 else ofproto.OFPTT_ALL
        cookie_mask = cookie_mask if cookie_mask > -1 else 0xFFFFFFFFFFFFFFFF

        parser = datapath.ofproto_parser
        mod = parser.OFPFlowMod(datapath=datapath, table_id=table_id,
                                cookie=cookie,
                                cookie_mask=cookie_mask,
                                match=match, command=ofproto.OFPFC_DELETE,
                                out_port=out_port, out_group=out_group)

        return mod

    @staticmethod
    def send_messages(datapath, msg_list, barrier=False):
        """
        Send all messages to the switch, followed by a Barrier request message, if requested.
        """

        for msg in msg_list:
            datapath.send_msg(msg)

        if barrier:
            # Send_barrier_request
            parser = datapath.ofproto_parser
            datapath.send_msg(parser.OFPBarrierRequest(datapath))

