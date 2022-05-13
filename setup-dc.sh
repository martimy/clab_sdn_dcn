#!/bin/bash

# Global Settings
SPINE1=spine1
SPINE2=spine2
LEAF1=leaf1
LEAF2=leaf2
LEAF3=leaf3

IP_CTRL=172.10.10.10
IP_PORT=6653

OF_VER=OpenFlow13
FAIL_MODE=secure

SFLOW=172.10.10.100

echo Create switches
ovs-vsctl --may-exist add-br $SPINE1
ovs-vsctl --may-exist add-br $SPINE2
ovs-vsctl --may-exist add-br $LEAF1
ovs-vsctl --may-exist add-br $LEAF2
ovs-vsctl --may-exist add-br $LEAF3

echo Set MAC address
# comment for random addresses
ovs-vsctl set bridge $SPINE1 other-config:hwaddr=00:00:00:00:00:0B
ovs-vsctl set bridge $SPINE2 other-config:hwaddr=00:00:00:00:00:0C
ovs-vsctl set bridge $LEAF1 other-config:hwaddr=00:00:00:00:00:15
ovs-vsctl set bridge $LEAF2 other-config:hwaddr=00:00:00:00:00:16
ovs-vsctl set bridge $LEAF3 other-config:hwaddr=00:00:00:00:00:17

echo Connect switches
ovs-vsctl --may-exist add-port $SPINE1 sl11 -- set interface sl11 type=patch options:peer=ls11
ovs-vsctl --may-exist add-port $SPINE1 sl12 -- set interface sl12 type=patch options:peer=ls21
ovs-vsctl --may-exist add-port $SPINE1 sl13 -- set interface sl13 type=patch options:peer=ls31
ovs-vsctl --may-exist add-port $SPINE2 sl21 -- set interface sl21 type=patch options:peer=ls12
ovs-vsctl --may-exist add-port $SPINE2 sl22 -- set interface sl22 type=patch options:peer=ls22
ovs-vsctl --may-exist add-port $SPINE2 sl23 -- set interface sl23 type=patch options:peer=ls32

ovs-vsctl --may-exist add-port $LEAF1 ls11 -- set interface ls11 type=patch options:peer=sl11
ovs-vsctl --may-exist add-port $LEAF1 ls12 -- set interface ls12 type=patch options:peer=sl21
ovs-vsctl --may-exist add-port $LEAF2 ls21 -- set interface ls21 type=patch options:peer=sl12
ovs-vsctl --may-exist add-port $LEAF2 ls22 -- set interface ls22 type=patch options:peer=sl22
ovs-vsctl --may-exist add-port $LEAF3 ls31 -- set interface ls31 type=patch options:peer=sl13
ovs-vsctl --may-exist add-port $LEAF3 ls32 -- set interface ls32 type=patch options:peer=sl23

echo Set switch options
for BR in $SPINE1 $SPINE2 $LEAF1 $LEAF2 $LEAF3
do
  ovs-vsctl set bridge $BR fail_mode=$FAIL_MODE
  ovs-vsctl set bridge $BR protocols=$OF_VER
  ovs-vsctl set-controller $BR tcp:$IP_CTRL:$IP_PORT
done

# uncomment the following if you wont to use sflow
# echo Setup sflow
# for BR in $SPINE1 $SPINE2 $LEAF1 $LEAF2 $LEAF3
# do
#   ovs-vsctl -- --id=@sflow create sflow agent=$BR target=$SFLOW \
#     sampling=100 polling=10 -- set bridge $BR sflow=@sflow
# done

