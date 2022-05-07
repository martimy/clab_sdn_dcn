# Software Defined Data Centre lab

This lab creates a software-defined data centre network using spine-leaf architecture built with Open-vSwitch switches.

![](img/sddcn.png)


# Requirements

To use this lab, you need to install containerlab. You also need to have basic familiarity with Docker.

This lab uses the following Docker images (they will be pulled automatically when you start the lab):

- martimy/ryu-flowmanager:latest — includes a [Ryu](https://github.com/faucetsdn/ryu) controller and [FlowManager](https://github.com/martimy/flowmanager).
- wbitt/network-multitool:alpine-minimal — a Linux with simple tools

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
