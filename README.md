# A Software Defined Networking lab


# To start

You must create the switches first, then deploy the lab:

```
sudo ./setup-bridges.sh
sudo clab deploy -t sdn-dcn.clab.yml 
```

Run Ryu controller with any number of apps. For example:

```
docker exec clab-sdn-dcn-ctrl ryu-manager flowmanager/flowmanager.py --verbose
```

# To end the lab

Do cleanup:

```
sudo clab destroy -t sdn-dcn.clab.yml --cleanup
sudo ./reset-bridges.sh
```

# Try this

To access the FlowManager GUI, direct your browser to http://localhost:8080/home/ from your host machine. If the host does not have a desktop or if you want to access it remotly use:

```
ssh -L 8080:172.20.20.5:8080 -p 2222 user@remotehost
```

replace user@remotehost with the username and address of your host machine. Replace 172.20.20.5 with the IP address given to the controller container. To find this address:

```
$ sudo clab inspect -a
```



