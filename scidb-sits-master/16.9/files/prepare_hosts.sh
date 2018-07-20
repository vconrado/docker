#!/bin/bash

LOCK=/data/prepare_hosts.lock

if [ $# -eq 0 ]; then
	echo "Usage: ${0} CLUSTER_NAME WORKER1 WORKER2 ... WORKERN"
	exit 1
fi

if [ -f $LOCK ]; then
	echo "Please, run only once this script."
	echo "If you want to run again, please remove the file $LOCK before."
	exit 1
fi
sudo touch $LOCK

CLUSTER=$1

sudo -E bash -c "echo host all all 10.0.0.0/24 md5 >> /etc/postgresql/9.3/main/pg_hba.conf"
sudo service postgresql restart

echo "scidb-01:5432:${CLUSTER}:postgres:postgres" | sudo tee --append /root/.pgpass
sudo chmod 600 /root/.pgpass

sudo cp /root/.pgpass /var/lib/postgresql/.pgpass
sudo chown postgres:postgres /var/lib/postgresql/.pgpass

sudo cp /root/.pgpass /home/scidb/.pgpass
sudo chown scidb:scidb /home/scidb/.pgpass
for HOST in "${@:2}"; do
	scp /home/scidb/.pgpass scidb@${HOST}:/home/scidb
	sudo scp /root/.pgpass root@${HOST}:/root
done

sudo -u postgres -E bash -c "$SCIDB_INSTALL_PATH/bin/scidb.py init_syscat ${CLUSTER}"
$SCIDB_INSTALL_PATH/bin/scidb.py initall ${CLUSTER}

echo "In order to start SciDB, execute: scidb.py startall $CLUSTER"

