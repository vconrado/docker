# Docker Scidb 16.9 with stream plugin

Scripts for building a Docker image of SciDB 16.9 with stream plugin

## Build the Docker image

To build the Docker image, execute the follow commands 
```bash
git clone https://github.com/e-sensing/docker
cd docker/scidb-stream/16.9
docker build --tag scidb-stream:16.9 .
```

## Running SciDB container
In order to start the SciDB container, type the following command in your terminal:
```bash
docker run -it -d --name scidb -e "CLUSTER=mydb" scidb-stream:16.9
```

