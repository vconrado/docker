#!/bin/bash
sudo service ssh start

#sudo service postgresql start

#wait_for_postgres.sh

#if [ ! -f ${DATA_DIR}/scidb.config.lock ]; then
#      sudo touch ${DATA_DIR}/scidb.config.lock
#      echo "First startup"
#      echo "Configurating SciDB cluster [${CLUSTER}]"
#      # Creating Data folder and changing owner to scidb
#      sudo mkdir -p $DATA_DIR/scidb
#      sudo chown -R scidb:scidb $DATA_DIR/scidb
#      create_scidb_cluster.sh $CLUSTER
#      scidb.py startall $CLUSTER
#      # Configuring SciDB Plugins
#      iquery -aq "load_library('dev_tools');"
#      echo "Installing Stream..."
#      iquery -aq "install_github('paradigm4/stream', 'd3f5393e5a9a8eba6f8ff777105ef031f48e3d3d');"
#      iquery -aq "load_library('stream');"
#    else
#      scidb.py startall $CLUSTER
#fi

trap "scidb.py stopall ${CLUSTER}; sudo service postgresql stop" EXIT HUP INT QUIT TERM

bash

