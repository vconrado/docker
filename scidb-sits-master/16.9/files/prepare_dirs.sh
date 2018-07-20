#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: ${0} CLUSTER_ID"
	exit 1
fi


BP=$(grep base-path config.ini | head -n 1 | cut -d= -f2)
echo "Creating base-path $BP"
mkdir -p $BP
chown -R scidb:scidb $BP


echo "Creating data-dir-prefix"
grep data-dir-prefix-${1} /opt/scidb/16.9/etc/config.ini | cut -d= -f2 | while read -r dir ; do
	echo "Creating $dir ...  "
	mkdir -p $dir
	chown -R scidb:scidb $dir
done
for i in 1 2 3 4 5 6 7 8; do
	chown -R scidb:scidb /disks/d${i}/scidb
done

echo "Done"
