#!/bin/bash
# docker-file scidb 18.1
sudo service ssh start

sudo service postgresql start
wait_for_postgres.sh

trap "/opt/scidb/18.1/bin/scidb.py stopall mydb; sudo service postgresql stop" EXIT HUP INT QUIT TERM

# start scidb
/opt/scidb/18.1/bin/scidb.py startall mydb

# run bash
bash

