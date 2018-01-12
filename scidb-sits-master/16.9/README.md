# Docker Scidb 16.9 Multinode

In this exemple, we will show how to run a Dockerized Scidb Multinode Server in 5 hosts.
Hosts are named: host1, host2, host3, host4 and host5, while containers are named scidb-01, scidb-02, scidb-03, scidb-04, scidb-05. 

# Preparing overlay network

In order to allow each container do communicate to each others, we will use an overlay network.
![Overlay Network example](http://blog.nigelpoulton.com/wp-content/uploads/2016/10/Figure8-2-1024x586.png "Overlay Network example")

First, it is necessary to create a swarm and attach all hosts. On the master host (**host1**) type the following command in the terminal: 

```bash
docker swarm create
```
This command will show the command that you must use in the others hosts:
```
docker swarm join \
    --token SWMTKN-1-3j ... axoe5djhd \
    [IP]:2377
```
**Copy and past this command on each host (host2, host3, host4 and host5).**

## Creating overlay network

In order to create the overlay network, type the following command on the **host1**:

```bash
docker network create -d overlay --attachable scidb_net
```


# Running Master SciDB (host1)

In order to run the Master SciDB Instance on **host1**, type the following command on the **host1**:

```bash

docker volume create scidb-data
docker volume create scidb-pg

docker run -it -d -v scidb-data:/data -v scidb-pg:/var/lib/postgresql/data -v /disks/d1:/disks/d1 -v /disks/d2:/disks/d2 -v /disks/d3:/disks/d3 -v /disks/d4:/disks/d4 -v /disks/d5:/disks/d5 -v /disks/d6:/disks/d6 -v /disks/d7:/disks/d7 -v /disks/d8:/disks/d8 -v /disks/d8/shared_disk/scidb/etc:/opt/scidb/16.9/etc -v /disks/d8/shared_disk/scidb/shared:/shared --name scidb-01 --restart unless-stopped --network scidb_net terrama2.dpi.inpe.br:443/scidb-sits-master:16.9
```

# Running Workers SciDB (host2, host3, host4, host5)

On each worker host (2, 3, 4 and 5) type the following command changing the instance name (**NN**):

```bash
docker run -it -d -v /disks/d1:/disks/d1 -v /disks/d2:/disks/d2 -v /disks/d3:/disks/d3 -v /disks/d4:/disks/d4 -v /disks/d5:/disks/d5 -v /disks/d6:/disks/d6 -v /disks/d7:/disks/d7 -v /disks/d8:/disks/d8 -v /disks/d8/shared_disk/scidb/etc:/opt/scidb/16.9/etc -v /disks/d8/shared_disk/scidb/shared:/shared --name scidb-02 --restart unless-stopped --network scidb_net terrama2.dpi.inpe.br:443/scidb-sits-worker:16.9

docker run -it -d -v /disks/d1:/disks/d1 -v /disks/d2:/disks/d2 -v /disks/d3:/disks/d3 -v /disks/d4:/disks/d4 -v /disks/d5:/disks/d5 -v /disks/d6:/disks/d6 -v /disks/d7:/disks/d7 -v /disks/d8:/disks/d8 -v /disks/d8/shared_disk/scidb/etc:/opt/scidb/16.9/etc -v /disks/d8/shared_disk/scidb/shared:/shared --name scidb-03 --restart unless-stopped --network scidb_net terrama2.dpi.inpe.br:443/scidb-sits-worker:16.9

docker run -it -d -v /disks/d1:/disks/d1 -v /disks/d2:/disks/d2 -v /disks/d3:/disks/d3 -v /disks/d4:/disks/d4 -v /disks/d5:/disks/d5 -v /disks/d6:/disks/d6 -v /disks/d7:/disks/d7 -v /disks/d8:/disks/d8 -v /disks/d8/shared_disk/scidb/etc:/opt/scidb/16.9/etc -v /disks/d8/shared_disk/scidb/shared:/shared --name scidb-04 --restart unless-stopped --network scidb_net terrama2.dpi.inpe.br:443/scidb-sits-worker:16.9


docker run -it -d -v /disks/d1:/disks/d1 -v /disks/d2:/disks/d2 -v /disks/d3:/disks/d3 -v /disks/d4:/disks/d4 -v /disks/d5:/disks/d5 -v /disks/d6:/disks/d6 -v /disks/d7:/disks/d7 -v /disks/d8:/disks/d8 -v /disks/d8/shared_disk/scidb/etc:/opt/scidb/16.9/etc -v /disks/d8/shared_disk/scidb/shared:/shared --name scidb-05 --restart unless-stopped --network scidb_net terrama2.dpi.inpe.br:443/scidb-sits-worker:16.9
```

# Configuring Master Node 

To run commands on Master SciDB instance, type the following command on **host1** terminal: 
```bash
docker exec -it scidb-01 bash
```

## Creating config.ini

Create the config.ini. In this example, we are using the folling config.ini

```bash
[esensing]
server-0=scidb-01,7
server-1=scidb-02,7
server-2=scidb-03,7
server-3=scidb-04,7
server-4=scidb-05,7
db_user=postgres
redundancy=0
install_root=/opt/scidb/16.9
pluginsdir=/opt/scidb/16.9/lib/scidb/plugins
logconf=/opt/scidb/16.9/share/scidb/log4cxx.properties
base-path=/disks/d1/scidb/esensing
base-port=1239
interface=eth0
security=trust

# scidb-01
data-dir-prefix-0-0=/disks/d1/scidb/esensing.0.0
data-dir-prefix-0-1=/disks/d2/scidb/esensing.0.1
data-dir-prefix-0-2=/disks/d3/scidb/esensing.0.2
data-dir-prefix-0-3=/disks/d4/scidb/esensing.0.3
data-dir-prefix-0-4=/disks/d5/scidb/esensing.0.4
data-dir-prefix-0-5=/disks/d6/scidb/esensing.0.5
data-dir-prefix-0-6=/disks/d7/scidb/esensing.0.6
data-dir-prefix-0-7=/disks/d8/scidb/esensing.0.7
# scidb-02
data-dir-prefix-1-0=/disks/d1/scidb/esensing.1.0
data-dir-prefix-1-1=/disks/d2/scidb/esensing.1.1
data-dir-prefix-1-2=/disks/d3/scidb/esensing.1.2
data-dir-prefix-1-3=/disks/d4/scidb/esensing.1.3
data-dir-prefix-1-4=/disks/d5/scidb/esensing.1.4
data-dir-prefix-1-5=/disks/d6/scidb/esensing.1.5
data-dir-prefix-1-6=/disks/d7/scidb/esensing.1.6
data-dir-prefix-1-7=/disks/d8/scidb/esensing.1.7
# scidb-03
data-dir-prefix-2-0=/disks/d1/scidb/esensing.2.0
data-dir-prefix-2-1=/disks/d2/scidb/esensing.2.1
data-dir-prefix-2-2=/disks/d3/scidb/esensing.2.2
data-dir-prefix-2-3=/disks/d4/scidb/esensing.2.3
data-dir-prefix-2-4=/disks/d5/scidb/esensing.2.4
data-dir-prefix-2-5=/disks/d6/scidb/esensing.2.5
data-dir-prefix-2-6=/disks/d7/scidb/esensing.2.6
data-dir-prefix-2-7=/disks/d8/scidb/esensing.2.7
# scidb-04
data-dir-prefix-3-0=/disks/d1/scidb/esensing.3.0
data-dir-prefix-3-1=/disks/d2/scidb/esensing.3.1
data-dir-prefix-3-2=/disks/d3/scidb/esensing.3.2
data-dir-prefix-3-3=/disks/d4/scidb/esensing.3.3
data-dir-prefix-3-4=/disks/d5/scidb/esensing.3.4
data-dir-prefix-3-5=/disks/d6/scidb/esensing.3.5
data-dir-prefix-3-6=/disks/d7/scidb/esensing.3.6
data-dir-prefix-3-7=/disks/d8/scidb/esensing.3.7
# scidb-05
data-dir-prefix-4-0=/disks/d1/scidb/esensing.4.0
data-dir-prefix-4-1=/disks/d2/scidb/esensing.4.1
data-dir-prefix-4-2=/disks/d3/scidb/esensing.4.2
data-dir-prefix-4-3=/disks/d4/scidb/esensing.4.3
data-dir-prefix-4-4=/disks/d5/scidb/esensing.4.4
data-dir-prefix-4-5=/disks/d6/scidb/esensing.4.5
data-dir-prefix-4-6=/disks/d7/scidb/esensing.4.6
data-dir-prefix-4-7=/disks/d8/scidb/esensing.4.7
```

PS: Don't forged to create the folders setted in config.ini file.

## Prepare cluster environment

In order to configure and share postgres password and configure a new cluster on scidb, type the following command on **host1** terminal:
```bash
/home/scidb/Devel/prepare_hosts.sh esensing scidb-02 scidb-03 scidb-04 scidb-05
```
If asked, type **y** and ENTER.

## Starting 

In order to start scidb, type the following command on container **scidb-01**:
```bash
scidb.py startall esensing
``'

# Installing Stream 

In order to enable SciDB Stream on all hosts, type the following commands on **scidb-01**:
```bash
iquery -aq "load_library('dev_tools');"
iquery -aq "install_github('paradigm4/stream', 'd3f5393e5a9a8eba6f8ff777105ef031f48e3d3d');"
iquery -aq "load_library('stream');"
```
