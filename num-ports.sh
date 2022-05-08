#!/bin/bash

echo Set desired port numbers
ovs-vsctl set Interface p1 ofport_request=3
ovs-vsctl set Interface p2 ofport_request=4
ovs-vsctl set Interface p3 ofport_request=3
ovs-vsctl set Interface p4 ofport_request=4
ovs-vsctl set Interface p5 ofport_request=3
ovs-vsctl set Interface p6 ofport_request=4

