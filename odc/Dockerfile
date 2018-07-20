FROM ubuntu:18.04
LABEL maintainer="Vitor Gomes <vconrado@gmail.com>"

# Fonte: https://github.com/opendatacube/datacube-core/blob/develop/Dockerfile

ENV DATA_DIR=/datacube


EXPOSE 80

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

ENV ODC_USR=datacube
ENV ODC_PASS=datacube
ENV ROOT_PASS=datacube
ENV APPDIR=/home/$ODC_USR/code


RUN groupadd $ODC_USR \
    && useradd $ODC_USR -s /bin/bash -m -g $ODC_USR \
    && echo $ODC_USR:$ODC_PASS | chpasswd  \
    && echo root:$ROOT_PASS | chpasswd  \
    && mkdir -p $APPDIR \
    && chown $ODC_USR:$ODC_USR $APPDIR \
    && mkdir -p $DATA_DIR \
    && chown $ODC_USR:$ODC_USR $DATA_DIR \
    && mkdir -p /opt/odc \
    && chown $ODC_USR:$ODC_USR /opt/odc

# First add the NextGIS repo
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:nextgis/ppa

# And now install apt dependencies, including a few of the heavy Python projects
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core requirements from travis.yml
    gdal-bin gdal-data libgdal-dev libgdal20 libudunits2-0 \
    # Extra python components, to speed things up
    python3 python3-setuptools python3-dev \
    python3-numpy python3-netcdf4 python3-gdal \
    # Need pip to install more python packages later.
    # The libdpkg-perl is needed to build pyproj
    python3-pip python3-wheel libdpkg-perl \
    # G++ because GDAL decided it needed compiling
    g++ \
    # Added by Vitor Gomes
    vim \
    wget \
    postgresql-client \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN echo "$ODC_USR ALL=(ALL:ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo

USER $ODC_USR

RUN git clone https://github.com/opendatacube/datacube-core.git $APPDIR

WORKDIR $APPDIR

# Set the locale, this is required for some of the Python packages
ENV LC_ALL C.UTF-8

# Install psycopg2 as a special case, to quiet the warning message 
RUN pip3 install --no-cache --no-binary :all: psycopg2-binary \
    && rm -rf $HOME/.cache/pip

RUN pip3 install shapely \
    && rm -rf $HOME/.cache/pip
# Now use the setup.py file to identify dependencies
RUN pip3 install '.[test,celery,s3]' --upgrade \
    && rm -rf $HOME/.cache/pip

# Install ODC
RUN sudo python3 setup.py install

# Move docs and utils somewhere else, and remove the temp folder
RUN mkdir -p /opt/odc \
    && chmod +rwx /opt/odc \
    && mv $APPDIR/utils /opt/odc/ \
    && mv $APPDIR/docs /opt/odc/ 
    #&& rm -rf $APPDIR

# Set up an entrypoint that drops environment variables into the config file
COPY files/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

WORKDIR /home/datacube
USER datacube
