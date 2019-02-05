# Tutorial on Network and Security with OpenFlow and ModSecurity

## Prerequisites
- Have Ubuntu 16
- Install docker and docker-compose
- Install VNC Viewer

##  Containernet
Containernet is a fork of the famous Mininet network emulator and allows to use Docker containers as hosts in emulated network topologies.
This enables interesting functionalities to build networking/cloud emulators and testbeds.

### Install containernet and deploy a network topology
- git clone https://github.com/containernet/containernet.git
- docker pull containernet/containernet
- docker run --name containernet -it --rm --privileged --pid='host' -v /var/run/docker.sock:/var/run/docker.sock containernet/containernet /bin/bash


### Deploy a simple network topology
- cd /containernet/examples
- python containernet_example.py (modify it to include the line "d1 = net.addDocker('d1', ip='10.0.0.251', dimage="ubuntu:trusty", ports=["5900"])")

Now open a new terminal and check that you have two containers 'mn.d1' and 'mn.d2' installed:
- docker ps
```
CONTAINER ID        IMAGE                                                                                      COMMAND                  CREATED             STATUS              PORTS                    NAMES
7c75a59c4c08        ubuntu:trusty                                                                              "/bin/bash"              2 minutes ago       Up 2 minutes                                 mn.d2
d8e7e1f44b8f        ubuntu:trusty                                                                              "/bin/bash"              2 minutes ago       Up 2 minutes                                 mn.d1
be6d235856f2        containernet                                                                               "util/docker/entrypo…"   20 hours ago        Up 20 hours                                  containernet
```

## Deploy the server and reverse proxy on the container 'mn.d2'

### Setting up the server
- In the cloned repository, execute the following command to copy files from your host to the container.
```
docker cp web.zip mn.d2:/web.zip
```
- Log in to the container mn.d2 to setup our webserver
```
docker exec -it mn.d2 /bin/bash
```
- Now, in the container, install the unzip package and unzip our file web.zip
```
apt-get update
apt-get install unzip
unzip web.zip
cd web
```

- Here are the steps to deploy your server
```
chmod +x presinstall.sh
bash presinstall.sh
cd /app
bash start.sh
cd /
wget https://github.com/dhatanian/ticketmagpie/archive/master.zip
unzip master.zip
cd /ticketmagpie-master
mvn spring-boot:run -Dspring.profiles.active=hsqldb
```


### Setting up the reverse proxy and Web application Firewall

```
cd /ticketmagpie-master; nohup mvn spring-boot:run -Dspring.profiles.active=hsqldb > /tmp/http_server.log 2>&1  &
cd /apache/ ; ./bin/httpd

```

## Setting up the VNC app in order to access Chrome from the host
- Copy needed files to the container
```
docker cp docker_chrome.sh mn.d1:/docker_chrome.sh
docker cp docker_chrome_prerequisite.sh mn.d1:/docker_chrome_prerequisite.sh

#launch mn.d1 container
chmod +x docker_chrome.sh
bash docker_chrome_prerequisite.sh
```
- Execute docker_chrome vnc app from a new terminal
```
docker exec --privileged --user apps  mn.d1  /docker_chrome.sh
```
