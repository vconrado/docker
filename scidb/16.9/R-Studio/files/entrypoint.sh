#!/bin/bash

/docker-entrypoint.sh &

rstudio-server start

trap "rstudio-server stop;" EXIT HUP INT QUIT TERM

bash
