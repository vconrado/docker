FROM terrama2.dpi.inpe.br:443/scidb:16.9
LABEL maintainer="e-sensing team <esensing-team@dpi.inpe.br>"

WORKDIR /tmp

# ##############################################################################
RUN git clone https://github.com/Paradigm4/dev_tools && \
    cd dev_tools && \
    make && \
    sudo cp *.so $SCIDB_INSTALL_PATH/lib/scidb/plugins && \
    cd .. && \
    rm -rf dev_tools && \
    sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
	
# ##############################################################################
COPY files/docker-entrypoint.sh /

# ##############################################################################
WORKDIR /home/${SCIDB_USR}
USER scidb

ENTRYPOINT  /docker-entrypoint.sh
