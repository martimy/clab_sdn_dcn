#!/bin/bash

echo Create bridges
ovs-vsctl --may-exist add-br br0
ovs-vsctl --may-exist add-br spine1
ovs-vsctl --may-exist add-br spine2
ovs-vsctl --may-exist add-br leaf1
ovs-vsctl --may-exist add-br leaf2
ovs-vsctl --may-exist add-br leaf3

echo Set bridge MAC address (or comment for random addresses)
ovs-vsctl set bridge spine1 other-config:hwaddr=00:00:00:00:00:01
ovs-vsctl set bridge spine2 other-config:hwaddr=00:00:00:00:00:02
ovs-vsctl set bridge leaf1 other-config:hwaddr=00:00:00:00:00:03
ovs-vsctl set bridge leaf2 other-config:hwaddr=00:00:00:00:00:04
ovs-vsctl set bridge leaf3 other-config:hwaddr=00:00:00:00:00:05

echo Enable STP
ovs-vsctl set Bridge br0 stp_enable=true
ovs-vsctl set Bridge br0 other_config:stp-priority=28672
ovs-vsctl set Bridge spine1 stp_enable=true
ovs-vsctl set Bridge spine2 stp_enable=true
ovs-vsctl set Bridge leaf1 stp_enable=true
ovs-vsctl set Bridge leaf2 stp_enable=true
ovs-vsctl set Bridge leaf3 stp_enable=true

echo Connect switches to ctrl bridge
ovs-vsctl add-port br0 patch1 -- set interface patch1 type=patch options:peer=patch_11
ovs-vsctl add-port br0 patch2 -- set interface patch2 type=patch options:peer=patch_12
ovs-vsctl add-port br0 patch3 -- set interface patch3 type=patch options:peer=patch_21
ovs-vsctl add-port br0 patch4 -- set interface patch4 type=patch options:peer=patch_22
ovs-vsctl add-port br0 patch5 -- set interface patch5 type=patch options:peer=patch_23

ovs-vsctl add-port spine1 patch_11 -- set interface patch_11 type=patch options:peer=patch1
ovs-vsctl add-port spine2 patch_12 -- set interface patch_12 type=patch options:peer=patch2
ovs-vsctl add-port leaf1 patch_21 -- set interface patch_21 type=patch options:peer=patch3
ovs-vsctl add-port leaf2 patch_22 -- set interface patch_22 type=patch options:peer=patch4
ovs-vsctl add-port leaf3 patch_23 -- set interface patch_23 type=patch options:peer=patch5

echo Connect switches to each other
ovs-vsctl add-port spine1 sl_11 -- set interface sl_11 type=patch options:peer=ls_11
ovs-vsctl add-port spine1 sl_12 -- set interface sl_12 type=patch options:peer=ls_21
ovs-vsctl add-port spine1 sl_13 -- set interface sl_13 type=patch options:peer=ls_31
ovs-vsctl add-port spine2 sl_21 -- set interface sl_21 type=patch options:peer=ls_12
ovs-vsctl add-port spine2 sl_22 -- set interface sl_22 type=patch options:peer=ls_22
ovs-vsctl add-port spine2 sl_23 -- set interface sl_23 type=patch options:peer=ls_32

ovs-vsctl add-port leaf1 ls_11 -- set interface ls_11 type=patch options:peer=sl_11
ovs-vsctl add-port leaf1 ls_12 -- set interface ls_12 type=patch options:peer=sl_21
ovs-vsctl add-port leaf2 ls_21 -- set interface ls_21 type=patch options:peer=sl_12
ovs-vsctl add-port leaf2 ls_22 -- set interface ls_22 type=patch options:peer=sl_22
ovs-vsctl add-port leaf3 ls_31 -- set interface ls_31 type=patch options:peer=sl_13
ovs-vsctl add-port leaf3 ls_32 -- set interface ls_32 type=patch options:peer=sl_23

echo Bring up the switchs internal port
ip link set spine1 up
ip link set spine2 up
ip link set leaf1 up
ip link set leaf2 up
ip link set leaf3 up

echo Assign IP address to the internal ports
ip addr add 10.0.0.11/24 dev spine1
ip addr add 10.0.0.12/24 dev spine2
ip addr add 10.0.0.21/24 dev leaf1
ip addr add 10.0.0.22/24 dev leaf2
ip addr add 10.0.0.23/24 dev leaf3

echo Setup the controller and protcols to use
ovs-vsctl set bridge spine1 protocols=OpenFlow13
ovs-vsctl set bridge spine2 protocols=OpenFlow13
ovs-vsctl set bridge leaf1 protocols=OpenFlow13
ovs-vsctl set bridge leaf2 protocols=OpenFlow13
ovs-vsctl set bridge leaf3 protocols=OpenFlow13
ovs-vsctl set-controller spine1 tcp:10.0.0.1:6633
ovs-vsctl set-controller spine2 tcp:10.0.0.1:6633
ovs-vsctl set-controller leaf1 tcp:10.0.0.1:6633
ovs-vsctl set-controller leaf2 tcp:10.0.0.1:6633
ovs-vsctl set-controller leaf3 tcp:10.0.0.1:6633



