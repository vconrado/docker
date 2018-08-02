# Docker Scidb 16.9

Scripts for building a Docker image of SciDB 16.9 with Shellinabox

## Build the Docker image

To build the Docker image, execute the follow commands 
```bash
git clone https://github.com/e-sensing/docker
cd docker/scidb-shellinabox/16.9
docker build --tag scidb-shellinabox:16.9 .
```

## Running SciDB container
In order to start the SciDB container, type the following command in your terminal:
```bash
docker run -p 4200:4200 --name shellinabox -e SIAB_ADDUSER=false scidb-shellinabox:16.9 
```

