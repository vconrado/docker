#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $(basename $0) cluster_name"
  exit 1
fi

SCIDB_RUNNING=$(ps -ef | grep SciDB | grep 1239 | wc -l)

if [[ "$SCIDB_RUNNING" -ne 0 ]]; then
  echo "You must stop scidb to create new cluster"
  echo "Use: $SCIDB_INSTALL_PATH/bin/scidb.py stopall CLUSTER_NAME"
  exit 2
fi

export DB=$1

echo "Updating config.ini ..."
echo -e "[${DB}]\n\
server-0=127.0.0.1,3\n\
db_user=postgres\n\
no-watchdog=true\n\
redundancy=0\n\
install_root=${SCIDB_INSTALL_PATH}\n\
pluginsdir=${SCIDB_INSTALL_PATH}/lib/scidb/plugins\n\
logconf=${SCIDB_INSTALL_PATH}/share/scidb/log4cxx.properties\n\
base-path=${DATA_DIR}/scidb/${SCIDB_VER}/${DB}\n\
base-port=1239\n\
interface=eth0\n\
pg-port=5432" | sudo -E bash -c "tee -a ${SCIDB_INSTALL_PATH}/etc/config.ini > /dev/null"

echo "Adding Cluster to PostgreSQL configuration ..."
POSTGRES_HOME=$(echo ~postgres)
echo "127.0.0.1:5432:${DB}:postgres:postgres" | sudo -E bash -c "tee -a /home/${SCIDB_USR}/.pgpass > /dev/null ${POSTGRES_HOME}/.pgpass /root/.pgpass"
sudo -E bash -c "chown ${SCIDB_USR}:${SCIDB_USR} /home/${SCIDB_USR}/.pgpass"
sudo -E bash -c "chown postgres:postgres ${POSTGRES_HOME}/.pgpass"
sudo -E bash -c "chown root:root /root/.pgpass"
sudo -E bash -c "chmod go-rwx /home/${SCIDB_USR}/.pgpass $POSTGRES_HOME/.pgpass /root/.pgpass"

echo "Initializing cluster ..."
sudo -u postgres -E bash -c "$SCIDB_INSTALL_PATH/bin/scidb.py init_syscat $DB"
yes | sudo -E bash -c "$SCIDB_INSTALL_PATH/bin/scidb.py initall $DB"
sudo chown -R ${SCIDB_USR}:${SCIDB_USR} /data/scidb

echo
echo "Done !"

