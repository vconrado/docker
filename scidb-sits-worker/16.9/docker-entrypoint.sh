#!/bin/bash
# scidb-stream:16.9 docker-entrypoint 

sudo service ssh start

if [ ! -d ${DATA_DIR}/scidb ]; then
      sudo mkdir -p ${DATA_DIR}/scidb
      # Creating Data folder and changing owner to scidb
      sudo chown -R scidb:scidb ${DATA_DIR}/scidb
fi

bash

