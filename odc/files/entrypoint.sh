#!/bin/bash

trap "sudo service postgresql stop" EXIT HUP INT QUIT TERM

sudo service postgresql start


if [ ! -d /datacube/original_data ]; then

	sudo mkdir -p /datacube/{original_data,ingested_data}
	sudo chown -R datacube:datacube /datacube
fi

echo "Use: "
echo "source ~/Datacube/datacube_env/bin/activate"

bash

