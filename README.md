# Software Defined Data Centre lab

This lab creates a software-defined data centre network using spine-leaf architecture built with Open-vSwitch switches.

![](img/sddcn.png)

## Requirements

To use this lab, you need to install containerlab. You also need to have basic familiarity with Docker.

This lab uses the following Docker images (they will be pulled automatically when you start the lab):

- martimy/ryu-flowmanager:latest — includes a [Ryu](https://github.com/faucetsdn/ryu) controller and [FlowManager](https://github.com/martimy/flowmanager).
- wbitt/network-multitool:alpine-minimal — a Linux with simple tools


## How does it work?

This lab builds an SDN network using [Open vSwitch](https://www.openvswitch.org/) (OVS) and [Docker](https://www.docker.com/) containers. These components are "glued" together using [containerlab](https://containerlab.dev/).

The Open vSwitch is an open-source virtual switch that is included in many Linux distribution. OVS is designed to work as a standalone switch that supports many standard management interfaces and protocols. OVS can also work as an SDN switch supporting OpenFlow protocol.

As an OpenFlow switch, on OVS needs an SDN controller. In this lab, the SDN controller used is [Ryu](https://ryu-sdn.org/). Ryu is installed in a Docker image along with FlowManager app, which provides a GUI access to the switches.

To emulate hosts in the data center, the lab includes a Docker image with pre-installed tools for testing.

Containerlab provides mechanisms to start Docker containers, build virtual topologies, and managing their lifecycle. A lab structure is provided in a YAML file that includes the containers to be deployed and their connections. However, containerlab, cannot create bridges (standard or OVS) other than the management bridge. Therefore, the bridges in this lab must be created externally using a shell script before deploy the containerlab topology. Also, another shell script is required to delete all bridges at the end of the lab.


## Starting and ending the lab

You must create the switches first, then deploy the lab:

```
sudo ./setup-dc.sh
sudo clab deploy -t sdn-dcn.clab.yml
```

Run Ryu controller with any number of apps. This example shows how to start the FlowManager app that allows you to populate the flow tables manually.

```
docker exec clab-sdn-dcn-ctrl ryu-manager flowmanager/flowmanager.py --verbose
```

To end the lab

```
sudo clab destroy -t sdn-dcn.clab.yml --cleanup
sudo ./reset-dc.sh
```

## Try this

To access the FlowManager GUI, direct your browser to http://localhost:8080/home/ from your host machine. If the host does not have a desktop or if you want to access it remotely use:

```
ssh -L 8080:172.20.20.5:8080 -p 2222 user@remotehost
```

Replace user@remotehost with the username and address of your host machine. Replace 172.20.20.5 with the IP address given to the controller container. To find this address:

```
$ sudo clab inspect -a
```
