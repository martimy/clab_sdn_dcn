#!/bin/bash

echo Create bridges
#ovs-vsctl --may-exist add-br br0
ovs-vsctl --may-exist add-br spine1
ovs-vsctl --may-exist add-br spine2
ovs-vsctl --may-exist add-br leaf1
ovs-vsctl --may-exist add-br leaf2
ovs-vsctl --may-exist add-br leaf3

ovs-ofctl del-flows spine1
ovs-ofctl del-flows spine2
ovs-ofctl del-flows leaf1
ovs-ofctl del-flows leaf2
ovs-ofctl del-flows leaf3

echo Set bridge MAC address, or comment for random addresses
ovs-vsctl set bridge spine1 other-config:hwaddr=00:00:00:00:00:01
ovs-vsctl set bridge spine2 other-config:hwaddr=00:00:00:00:00:02
ovs-vsctl set bridge leaf1 other-config:hwaddr=00:00:00:00:00:03
ovs-vsctl set bridge leaf2 other-config:hwaddr=00:00:00:00:00:04
ovs-vsctl set bridge leaf3 other-config:hwaddr=00:00:00:00:00:05

#echo Enable STP
#ovs-vsctl set Bridge br0 stp_enable=true
#ovs-vsctl set Bridge br0 other_config:stp-priority=28672
#ovs-vsctl set Bridge spine1 stp_enable=true
#ovs-vsctl set Bridge spine2 stp_enable=true
#ovs-vsctl set Bridge leaf1 stp_enable=true
#ovs-vsctl set Bridge leaf2 stp_enable=true
#ovs-vsctl set Bridge leaf3 stp_enable=true

#echo Connect switches to ctrl bridge
#ovs-vsctl add-port br0 ctrl1 -- set interface ctrl1 type=patch options:peer=ctrl11
#ovs-vsctl add-port br0 ctrl2 -- set interface ctrl2 type=patch options:peer=ctrl12
#ovs-vsctl add-port br0 ctrl3 -- set interface ctrl3 type=patch options:peer=ctrl21
#ovs-vsctl add-port br0 ctrl4 -- set interface ctrl4 type=patch options:peer=ctrl22
#ovs-vsctl add-port br0 ctrl5 -- set interface ctrl5 type=patch options:peer=ctrl23

#ovs-vsctl add-port spine1 ctrl11 -- set interface ctrl11 type=patch options:peer=ctrl1
#ovs-vsctl add-port spine2 ctrl12 -- set interface ctrl12 type=patch options:peer=ctrl2
#ovs-vsctl add-port leaf1 ctrl21 -- set interface ctrl21 type=patch options:peer=ctrl3
#ovs-vsctl add-port leaf2 ctrl22 -- set interface ctrl22 type=patch options:peer=ctrl4
#ovs-vsctl add-port leaf3 ctrl23 -- set interface ctrl23 type=patch options:peer=ctrl5

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

#echo Assign IP address to the internal ports
#ip addr add 10.0.0.11/24 dev ctrl11
#ip addr add 10.0.0.12/24 dev ctrl12
#ip addr add 10.0.0.21/24 dev ctrl21
#ip addr add 10.0.0.22/24 dev ctrl22
#ip addr add 10.0.0.23/24 dev ctrl23

echo Setup the controller and protcols to use
ovs-vsctl set bridge spine1 protocols=OpenFlow13
ovs-vsctl set bridge spine2 protocols=OpenFlow13
ovs-vsctl set bridge leaf1 protocols=OpenFlow13
ovs-vsctl set bridge leaf2 protocols=OpenFlow13
ovs-vsctl set bridge leaf3 protocols=OpenFlow13

ovs-vsctl set-controller spine1 tcp:172.10.10.10:6653
ovs-vsctl set-controller spine2 tcp:172.10.10.10:6653
ovs-vsctl set-controller leaf1 tcp:172.10.10.10:6653
ovs-vsctl set-controller leaf2 tcp:172.10.10.10:6653
ovs-vsctl set-controller leaf3 tcp:172.10.10.10:6653

echo Bring up the switchs internal port
#ip link set spine1 up
#ip link set spine2 up
#ip link set leaf1 up
#ip link set leaf2 up
#ip link set leaf3 up
