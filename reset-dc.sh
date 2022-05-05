#!/bin/bash

ovs-vsctl --if-exists del-br br0
ovs-vsctl --if-exists del-br spine1
ovs-vsctl --if-exists del-br spine2
ovs-vsctl --if-exists del-br leaf1
ovs-vsctl --if-exists del-br leaf2
ovs-vsctl --if-exists del-br leaf3
#ip link del dev br0
