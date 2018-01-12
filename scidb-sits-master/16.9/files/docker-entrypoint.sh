#!/bin/bash

sudo service ssh start

sudo service postgresql start
wait_for_postgres.sh

trap "scidb.py stopall ${CLUSTER}; sudo service postgresql stop" EXIT HUP INT QUIT TERM

bash

