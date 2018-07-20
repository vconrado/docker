#!/bin/bash
# scidb-stream:16.9 docker-entrypoint 

sudo service ssh start

sudo service postgresql start
wait_for_postgres.sh

if [ ! -d ${DATA_DIR}/scidb ]; then
      sudo mkdir -p ${DATA_DIR}/scidb
      # Creating Data folder and changing owner to scidb
      sudo chown -R scidb:scidb ${DATA_DIR}/scidb
fi

if [ ! -z "${CLUSTER}" ]; then
	# check if cluster exists
	if ! grep -Fxq "[${CLUSTER}]" ${SCIDB_INSTALL_PATH}/etc/config.ini 2> /dev/null; then
		echo "Creating cluster [${CLUSTER}]"
		create_scidb_cluster.sh ${CLUSTER}
	else
		echo "Cluster [${CLUSTER}] already exists."
	fi
	scidb.py startall $CLUSTER
else
        if [ ! -f ${SCIDB_INSTALL_PATH}/etc/config.ini ]; then
                >&2 echo "You must set environment variable CLUSTER."
                >&2 echo "Use: docker run -e \"CLUSTER=cluster_name\"  [..]"
		sudo service postgresql stop
		sudo service ssh stop
		exit 2
        else
                echo "Skipping cluster creation/initialization"
        fi
fi

STREAM_LOCK="${DATA_DIR}/scidb-stream.lock"

if [ ! -f "${STREAM_LOCK}" ]; then
      sudo touch ${STREAM_LOCK}
      echo "Installing Stream..."
      iquery -aq "load_library('dev_tools');"
      iquery -aq "install_github('paradigm4/stream', 'd3f5393e5a9a8eba6f8ff777105ef031f48e3d3d');"
      iquery -aq "load_library('stream');"
fi

trap "scidb.py stopall ${CLUSTER}; sudo service postgresql stop" EXIT HUP INT QUIT TERM

bash

