# Docker Scidb 16.9 Multinode

In this exemple, we will show how to run a Dockerized Scidb Multinode Server on 5 hosts (host1, host2, host3, host4 and host5).

# Preparing Docker overlay network

In order to allow each container do communicate to others container, we will use a overlay network.  [http://blog.nigelpoulton.com/wp-content/uploads/2016/10/Figure8-2-1024x586.png]
First, it is necessary to create a swarm with all hosts. On the master host (host1) type the following command in the terminal: 

```bash
docker swarm create
```
This commando will show the command that must be used on the others hosts:
```
docker swarm join \
    --token SWMTKN-1-3j ... axoe5djhd \
    [IP]:2377
```
Copy and Past this command on each host (host2, host3, host4 and host5)

To create the overlay network, type the following commando in the terminal:

```bash
docker network create -d overlay --attachable scidb_net
```


# Running Master (host1) SciDB

In order to run the Master Scidb Instance on host1, type the following command on the **host1**:

```bash
docker run -it -d -v /disks/d1:/data/d1 -v /disks/d2:/data/d2 -v /disks/d3:/data/d3 -v /disks/d4:/data/d4 -v /disks/d5:/data/d5 -v /disks/d6:/data/d6 -v /disks/d7:/data/d7 -v /disks/d8:/data/d8 --name scidb-01 --restart unless-stopped -e "CLUSTER=mydb" --network scidb_net terrama2.dpi.inpe.br:443/scidb-sits:16.9
```


# Running Workers (host2, host3, host4, host5) SciDB

On each host (2, 3, 4 and 5) type the following command changing the instance name:

```bash
docker run -it -d -v /disks/d1:/data/d1 -v /disks/d2:/data/d2 -v /disks/d3:/data/d3 -v /disks/d4:/data/d4 -v /disks/d5:/data/d5 -v /disks/d6:/data/d6 -v /disks/d7:/data/d7 -v /disks/d8:/data/d8 --name scidb-**NN** --restart unless-stopped --network scidb_net terrama2.dpi.inpe.br:443/scidb-sits-worker:16.9
```

# Configuring Master

To attach to a Master Scidb, type the following command on **host1** terminal: 
```bash
docker exec -it scidb-01 bash
```
On the container **scidb-01** terminal type:
```bash
scidb.py stopall mydb
```

Update the pg_hba.conf with the IP/MASK. 
```bash
sudo -E bash -c "echo host all all 10.0.0.0/24 md5 >> /etc/postgresql/9.3/main/pg_hba.conf"
sudo service postgresql restart
```


Download SciDB source-code:
```bash
cd /home/scidb/Devel/
sudo chown -R scidb:scidb /home/scidb/Devel/
mkdir -p scidb-16.9

export SCIDB_URL="https://docs.google.com/uc?id=0BzNaZtoQsmy2OG1WcXhiai1rak0&export=download"
wget --no-verbose --output-document scidb-16.9.0.db1a98f.tgz --load-cookies cookies.txt "$SCIDB_URL `wget --no-verbose --output-document - --save-cookies cookies.txt "$SCIDB_URL" | grep --only-matching 'confirm=[^&]*'`"
tar -xvzf scidb-16.9.0.db1a98f.tgz -C scidb-16.9
``


In order to configure SciDB, type the following command on **scidb-01**:
```bash
sudo su - 
cd /home/scidb/Devel/scidb-16.9
./deployment/deploy.sh scidb_prepare scidb scidb postgres postgres mydb01 /data/scidb/mydb01 2 default 1 default scidb-01 scidb-02 scidb-03 scidb-04 scidb-05
echo "scidb-01:5432:mydb01:postgres:postgres" >> /root/.pgpass
```

Copy /root/.pgpass para cada worker (ver de criar volume com /root)
```bash
scp /root/.pgpass root@scidb-02:/root/
scp /root/.pgpass root@scidb-03:/root/
scp /root/.pgpass root@scidb-04:/root/
scp /root/.pgpass root@scidb-05:/root/
```


# Running Scidb

```bash
scidb.py startall mydb01
```

Type **postgres** twice for the password and type 'y'.

# Installing Stream 

In order to enable SciDB Stream on all hosts, type the following commands on **scidb-01**:
```bash
iquery -aq "load_library('dev_tools');"
iquery -aq "install_github('paradigm4/stream', 'd3f5393e5a9a8eba6f8ff777105ef031f48e3d3d');"
iquery -aq "load_library('stream');"
```
    
    



