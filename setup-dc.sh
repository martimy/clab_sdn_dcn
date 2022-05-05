#!/bin/bash

echo Create bridges
ovs-vsctl add-br br0
ovs-vsctl add-br spine1
ovs-vsctl add-br spine2
ovs-vsctl add-br leaf1
ovs-vsctl add-br leaf2
ovs-vsctl add-br leaf3

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

