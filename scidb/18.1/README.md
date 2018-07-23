# Docker Scidb 18.1

Scripts for building a Docker image of SciDB 18.1

## Build the Docker image

To build the Docker image, execute the follow commands 
```bash
git clone https://github.com/e-sensing/docker 
cd docker/scidb/18.1
docker build --tag scidb:18.1 .
```

## Running SciDB container
In order to start the SciDB container, type the following command in your terminal:
```bash
docker run -it --name scidb -e scidb:18.1
```

