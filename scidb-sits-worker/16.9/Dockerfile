FROM terrama2.dpi.inpe.br:443/scidb-stream:16.9
LABEL maintainer="e-sensing team <esensing-team@dpi.inpe.br>"

WORKDIR /tmp

USER root
# ##############################################################################
RUN echo "deb https://cran.uni-muenster.de/bin/linux/ubuntu/ trusty/" | tee -a /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
    && gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 \
    && gpg -a --export E084DAB9 | sudo apt-key add - \
    && add-apt-repository ppa:ubuntugis/ubuntugis-unstable \
    && apt-get update \
    && apt-get install -y libcurl4-openssl-dev \
                          libssl-dev openssl \
                          libxml2-dev \
                          libproj-dev \
                          libudunits2-dev \
                          libgdal20 gdal-bin libgdal-dev \
                          libgl1-mesa-dev freeglut3 freeglut3-dev \
                          r-base r-base-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN R -e "install.packages('devtools', repos='https://ftp.gwdg.de/pub/misc/cran');\
library(devtools);\
install.packages('tidyverse', repos='https://ftp.gwdg.de/pub/misc/cran');\
library(tidyverse);\
install.packages('plyr', repos='https://ftp.gwdg.de/pub/misc/cran');\
library(plyr);\
install.packages('rgdal', repos='https://ftp.gwdg.de/pub/misc/cran');\
library(rgdal);\
install.packages('sf', repos='https://ftp.gwdg.de/pub/misc/cran');\
library(sf);\
install.packages('rgl', repos='https://ftp.gwdg.de/pub/misc/cran');\
library(rgl);\
install.packages('TSdist', repos='https://ftp.gwdg.de/pub/misc/cran');\
devtools::install_github('e-sensing/sits');\
library(sits)"
	
# ##############################################################################
WORKDIR /home/${SCIDB_USR}
USER scidb

ENTRYPOINT  /docker-entrypoint.sh
