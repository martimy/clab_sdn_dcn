#!/bin/bash

echo Create switches
ovs-vsctl --may-exist add-br spine1
ovs-vsctl --may-exist add-br spine2
ovs-vsctl --may-exist add-br leaf1
ovs-vsctl --may-exist add-br leaf2
ovs-vsctl --may-exist add-br leaf3

echo Set MAC address, or comment for random addresses
ovs-vsctl set bridge spine1 other-config:hwaddr=00:00:00:00:00:0B
ovs-vsctl set bridge spine2 other-config:hwaddr=00:00:00:00:00:0C
ovs-vsctl set bridge leaf1 other-config:hwaddr=00:00:00:00:00:15
ovs-vsctl set bridge leaf2 other-config:hwaddr=00:00:00:00:00:16
ovs-vsctl set bridge leaf3 other-config:hwaddr=00:00:00:00:00:17

echo Connect switches
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

echo Set switch options
ovs-vsctl set bridge spine1 fail_mode=secure
ovs-vsctl set bridge spine2 fail_mode=secure
ovs-vsctl set bridge leaf1 fail_mode=secure
ovs-vsctl set bridge leaf2 fail_mode=secure
ovs-vsctl set bridge leaf3 fail_mode=secure

ovs-vsctl set bridge spine1 protocols=OpenFlow13
ovs-vsctl set bridge spine2 protocols=OpenFlow13
ovs-vsctl set bridge leaf1 protocols=OpenFlow13
ovs-vsctl set bridge leaf2 protocols=OpenFlow13
ovs-vsctl set bridge leaf3 protocols=OpenFlow13

echo Set controller address
ovs-vsctl set-controller spine1 tcp:172.10.10.10:6653
ovs-vsctl set-controller spine2 tcp:172.10.10.10:6653
ovs-vsctl set-controller leaf1 tcp:172.10.10.10:6653
ovs-vsctl set-controller leaf2 tcp:172.10.10.10:6653
ovs-vsctl set-controller leaf3 tcp:172.10.10.10:6653
