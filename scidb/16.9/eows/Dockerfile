FROM ubuntu:14.04
MAINTAINER e-sensing team <esensing-team@dpi.inpe.br>

VOLUME /data
VOLUME /var/lib/postgresql/data


# ##############################################################################
# Exporting SCIDB and EOWS WebServer Port to be able to access through host machine
EXPOSE 1239
EXPOSE 7654

ARG CLUSTER=esensing
ARG MAKE_J=4

# ##############################################################################
# Configuration variables
ENV HOST_IP=127.0.0.1
ENV NET_MASK=$HOST_IP/8
ENV DATA_DIR=/data
ENV SCIDB_USR=scidb
ENV SCIDB_PASS=scidb
ENV SCIDB_VER=16.9
ENV DEV_DIR=/home/$SCIDB_USR/Devel
ENV SCIDB_INSTALL_PATH=/opt/scidb/${SCIDB_VER}
ENV SCIDB_BUILD_TYPE=RelWithDebInfo
ENV SCIDB_SOURCE_PATH=${DEV_DIR}/scidb-${SCIDB_VER}
ENV SCIDB_BUILD_PATH=${SCIDB_SOURCE_PATH}/stage/build
ENV PATH=$SCIDB_INSTALL_PATH/bin:$PATH


# ##############################################################################
# Copying scripts
COPY files/wait_for_postgres.sh /usr/local/bin
RUN chmod +x /usr/local/bin/wait_for_postgres.sh

   
# ##############################################################################
# Creating scidb user
RUN groupadd $SCIDB_USR \
    && useradd $SCIDB_USR -s /bin/bash -m -g $SCIDB_USR \
    && echo $SCIDB_USR:$SCIDB_PASS | chpasswd  \
    && mkdir -p $DEV_DIR \
    && chown $SCIDB_USR:$SCIDB_USR $DEV_DIR \
    && chmod g-w /home/$SCIDB_USR

# ##############################################################################
# Instaling dependencies
RUN apt-get update \
    && apt-get install -y  wget \
						   apt-transport-https \
						   software-properties-common \
						   expect \
						   openssh-server \
						   openssh-client \
						   vim

WORKDIR $DEV_DIR

# ##############################################################################
# Downloading SciDB 16.9
RUN export SCIDB_URL="https://docs.google.com/uc?id=0BzNaZtoQsmy2OG1WcXhiai1rak0&export=download" \
	&& wget --no-verbose --output-document scidb-16.9.0.db1a98f.tgz\
        --load-cookies cookies.txt \
        "$SCIDB_URL `wget --no-verbose --output-document - \
            --save-cookies cookies.txt "$SCIDB_URL" | \
            grep --only-matching 'confirm=[^&]*'`" \
    && mkdir scidb-${SCIDB_VER} \
    && tar -xzf scidb-16.9.0.db1a98f.tgz -C scidb-${SCIDB_VER}

WORKDIR scidb-${SCIDB_VER}

# ##############################################################################
# Providing Passwordless SSH
RUN service ssh start \
    && ssh-keygen -f /root/.ssh/id_rsa -N '' \
    && mkdir /home/$SCIDB_USR/.ssh \
    && ssh-keygen -f /home/$SCIDB_USR/.ssh/id_rsa -N '' \
    && chmod go-rwx /home/$SCIDB_USR/.ssh \
    && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
    && cat /root/.ssh/id_rsa.pub >> /home/$SCIDB_USR/.ssh/authorized_keys \
    && cat /home/$SCIDB_USR/.ssh/id_rsa.pub >> /home/$SCIDB_USR/.ssh/authorized_keys \
    && chown -R $SCIDB_USR:$SCIDB_USR /home/$SCIDB_USR \
    && ./deployment/deploy.sh access root NA "" $HOST_IP \
    && ./deployment/deploy.sh access $SCIDB_USR NA "" $HOST_IP \
    && ssh $HOST_IP date

# ##############################################################################
## Installing PostgreSQL
RUN service ssh start \
    && ./deployment/deploy.sh prepare_postgresql postgres postgres $NET_MASK $HOST_IP \
    && usermod -G $SCIDB_USR -a postgres \
    && chmod g+rx $DEV_DIR

# ##############################################################################
# Configuring Environment Variables in bashrc files
RUN echo "export SCIDB_VER=16.9\n\
export SCIDB_INSTALL_PATH=${SCIDB_INSTALL_PATH}\n\
export SCIDB_BUILD_TYPE=RelWithDebInfo\n\
export SCIDB_SOURCE_PATH=/home/scidb/Devel/scidb-${SCIDB_VER} \n\
export SCIDB_BUILD_PATH=/home/scidb/Devel/scidb-${SCIDB_VER}/stage/build\n\
export PATH=$SCIDB_INSTALL_PATH/bin:$PATH" | tee -a /root/.bashrc /home/$SCIDB_USR/.bashrc

# ##############################################################################
# Installing Build Tools SciDB
RUN service ssh start \
    && ./deployment/deploy.sh prepare_toolchain $HOST_IP
	
# ##############################################################################
# Building SciDB
RUN service ssh start \
	  && ./run.py setup --force \
    && ./run.py make -j${MAKE_J}

# ##############################################################################   
# Instaling SciDB
	RUN service ssh start \
    && yes n | ./run.py install --light \
    # Moving SciDB extern to SCIDB_INSTALL_PATH to fix Murmurhash dependency
    && mv ${SCIDB_SOURCE_PATH}/extern ${SCIDB_INSTALL_PATH}
    
# ##############################################################################   
# Configuring SciDB
RUN service postgresql start \
    && wait_for_postgres.sh\
    && sudo -u postgres psql -c "ALTER USER "postgres" WITH PASSWORD 'postgres';" \
    && POSTGRES_HOME=$(echo ~postgres) \    
 	  && mkdir -p ${DATA_DIR}/scidb \
    && chown -R ${SCIDB_USR}:${SCIDB_USR} ${DATA_DIR} \
    && chown -R scidb:scidb $SCIDB_INSTALL_PATH


# ##############################################################################
# EOWS - Configuration variables
ENV EOWS_PATH=$DEV_DIR/eows
ENV EOWS_DEPENDENCIES_DIR=$EOWS_PATH/3rdparty
ENV EOWS_CODEBASE=$EOWS_PATH/codebase
ENV EOWS_BUILD_DIR=$EOWS_PATH/build-release
ENV EOWS_INSTALL_DIR=/opt/eows/0.5.0

# ##############################################################################
# Installing CMAKE 3.X
RUN mkdir -p $EOWS_DEPENDENCIES_DIR $EOWS_CODEBASE $EOWS_BUILD_DIR \
    && cd ${EOWS_DEPENDENCIES_DIR} \
    && apt-get remove cmake* -y \
    && apt-get install curl -y \
    && curl -O https://cmake.org/files/v3.7/cmake-3.7.2.tar.gz \
    && tar -zxf cmake-3.7.2.tar.gz \
    
    && cd cmake-3.7.2 \
    && ./configure \
    && make && make install \
    && cd ${EOWS_DEPENDENCIES_DIR} \
    && rm -rf cmake-3.7.*

# ##############################################################################
# Configure EOWS
RUN git clone https://github.com/e-sensing/eows.git $EOWS_CODEBASE \
    && cd $EOWS_DEPENDENCIES_DIR \
    && cp $EOWS_CODEBASE/bash/install-3rdparty-linux-ubuntu-14.04.sh . \
    && curl -O http://www.dpi.inpe.br/foss/eows/eows-3rdparty-0.5.0-linux-ubuntu-14.04.tar.gz \

    # Compile Dependendies
    && ./install-3rdparty-linux-ubuntu-14.04.sh $EOWS_DEPENDENCIES_DIR \

    && cd ${EOWS_DEPENDENCIES_DIR} \

    && rm -rf ${EOWS_DEPENDENCIES_DIR}/eows-3rdparty-0.5.0-linux-ubuntu-14*

# Build and Install EOWS
RUN cd $EOWS_BUILD_DIR \
    # Generate artifacts
    && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release \
                                 -DEOWS_SCIDB_MAJOR_VERSION="16" \
                                 -DCMAKE_INSTALL_PREFIX=$EOWS_INSTALL_DIR \
                                 -DCMAKE_PREFIX_PATH="$SCIDB_INSTALL_PATH;$SCIDB_INSTALL_PATH/3rdparty/boost;$EOWS_DEPENDENCIES_DIR" \
                                 -DEOWS_GDAL2_ENABLED=ON \
                                 -DEOWS_OGC_OWS_ENABLED=ON \
                                 -DEOWS_SERVICE_WCS_ENABLED=ON \
                                 # Changing CMake RPath settings.
                                 -DCMAKE_INSTALL_RPATH=$EOWS_INSTALL_DIR/lib \
                                 -DCMAKE_SKIP_BUILD_RPATH=OFF \
                                 -DCMAKE_BUILD_WITH_INSTALL_RPATH=OFF \
                                 -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
                                 $EOWS_CODEBASE/build/cmake \
    # Compile
    && make install -j${MAKE_J} \
    # Cleaning up
    && cd ${EOWS_DEPENDENCIES_DIR} \
    && rm -rf ${EOWS_CODEBASE} ${EOWS_BUILD_DIR}


# ##############################################################################
# Cleaning up
RUN rm ${DEV_DIR}/scidb-16.9.0.db1a98f.tgz $DEV_DIR/cookies.txt \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# ##############################################################################
# Creating docker-entry.sh
RUN echo '#!/bin/bash\n\
service ssh start \n\
service postgresql start \n\
wait_for_postgres.sh\n' | tee -a /docker-entrypoint.sh \
    && echo "if [ ! -f ${DATA_DIR}/scidb.config.lock ]; then\n\
      touch ${DATA_DIR}/scidb.config.lock\n\
      echo 'First startup' \n\
      echo 'Configurating SciDB cluster [$CLUSTER]' \n\
      # Creating Data folder and changing owner to scidb\n\
      mkdir -p $DATA_DIR/scidb\n\
      chown -R scidb:scidb $DATA_DIR/scidb\n\
      create_scidb_cluster.sh $CLUSTER\n\
    fi" | tee -a /docker-entrypoint.sh \
    && echo "scidb.py startall $CLUSTER" | tee -a /docker-entrypoint.sh \
    && echo "$EOWS_INSTALL_DIR/bin/eows_app_server --base-dir $EOWS_INSTALL_DIR &" | tee -a /docker-entrypoint.sh \
    && echo "trap \"scidb.py stopall $CLUSTER; service postgresql stop\" EXIT HUP INT QUIT TERM \n\
bash " | tee -a /docker-entrypoint.sh \
    && chmod +x /docker-entrypoint.sh

COPY files/create_scidb_cluster.sh /usr/local/bin
RUN  chmod +x /usr/local/bin/create_scidb_cluster.sh

ENTRYPOINT  /docker-entrypoint.sh



