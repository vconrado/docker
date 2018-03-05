#!/bin/bash

trap "sudo service postgresql stop" EXIT HUP INT QUIT TERM

sudo service postgresql start

#source ~/Datacube/datacube_env/bin/activate 

bash

