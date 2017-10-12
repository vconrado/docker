#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

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

DB=$1

echo -e "[${DB}]\n\
server-0=127.0.0.1,3\n\
db_user=postgres\n\
no-watchdog=true\n\
redundancy=0\n\
install_root=${SCIDB_INSTALL_PATH}\n\
pluginsdir=${SCIDB_INSTALL_PATH}/lib/scidb/plugins\n\
logconf=${SCIDB_INSTALL_PATH}/share/scidb/log4cxx.properties\n\
base-path=${DATA_DIR}/scidb/${SCIDB_VER}/${DEFAULT_DB}\n\
base-port=1239\n\
interface=eth0\n\
pg-port=5432" | tee -a ${SCIDB_INSTALL_PATH}/etc/config.ini

POSTGRES_HOME=$(echo ~postgres)
echo "127.0.0.1:5432:${DB}:postgres:postgres" | tee -a /home/${SCIDB_USR}/.pgpass ${POSTGRES_HOME}/.pgpass /root/.pgpass

sudo -u postgres $SCIDB_INSTALL_PATH/bin/scidb.py init_syscat $DB
yes | $SCIDB_INSTALL_PATH/bin/scidb.py initall $DB
