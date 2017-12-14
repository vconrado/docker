# Docker Scidb 16.9 and EOWS 0.5.0

Scripts for building a Docker image of SciDB 16.9 and [EOWS](http://github.com/e-sensing/eows) 0.5.0.

## Build the Docker image

To build the Docker image, execute the follow commands 
```bash
git clone https://github.com/e-sensing/docker 
cd docker/scidb/16.9/eows
docker build --tag scidb-eows:16.9 .
```

