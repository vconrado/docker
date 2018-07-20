FROM ubuntu:14.04
LABEL maintainer="e-sensing team <esensing-team@dpi.inpe.br>"

VOLUME /data
VOLUME /var/lib/postgresql/data


# ##############################################################################
# Exporting SCIDB and EOWS WebServer Port to be able to access through host machine
EXPOSE 1239
EXPOSE 7654

ARG MAKE_J=16

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
						   vim \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
    && tar -xzf scidb-16.9.0.db1a98f.tgz -C scidb-${SCIDB_VER} \
    && rm scidb-16.9.0.db1a98f.tgz cookies.txt

WORKDIR scidb-${SCIDB_VER}

# ##############################################################################
RUN service ssh start \
    && ssh-keygen -f /root/.ssh/id_rsa -N '' \
    && mkdir /home/$SCIDB_USR/.ssh \
    && ssh-keygen -f /home/$SCIDB_USR/.ssh/id_rsa -N '' \
    && chmod go-rwx /home/$SCIDB_USR/.ssh \
    && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
    && cat /root/.ssh/id_rsa.pub >> /home/$SCIDB_USR/.ssh/authorized_keys \
    && cat /home/$SCIDB_USR/.ssh/id_rsa.pub >> /home/$SCIDB_USR/.ssh/authorized_keys \
    && cat /home/$SCIDB_USR/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
    && chown -R $SCIDB_USR:$SCIDB_USR /home/$SCIDB_USR \
    && ./deployment/deploy.sh access root NA "" $HOST_IP \
    && ./deployment/deploy.sh access $SCIDB_USR NA "" $HOST_IP \
    && ssh $HOST_IP date \
    && ./deployment/deploy.sh prepare_postgresql postgres postgres $NET_MASK $HOST_IP \
    && usermod -G $SCIDB_USR -a postgres \
    && chmod g+rx $DEV_DIR \
    && echo "export SCIDB_VER=16.9\n\
export SCIDB_INSTALL_PATH=${SCIDB_INSTALL_PATH}\n\
export SCIDB_BUILD_TYPE=RelWithDebInfo\n\
export SCIDB_SOURCE_PATH=/home/scidb/Devel/scidb-${SCIDB_VER} \n\
export SCIDB_BUILD_PATH=/home/scidb/Devel/scidb-${SCIDB_VER}/stage/build\n\
export PATH=$SCIDB_INSTALL_PATH/bin:$PATH" | tee -a /root/.bashrc /home/$SCIDB_USR/.bashrc \
    && ./deployment/deploy.sh prepare_toolchain $HOST_IP \
    && ./run.py setup --force \
    && ./run.py make -j${MAKE_J} \
    && yes n | ./run.py install --light \
    # Moving SciDB extern to SCIDB_INSTALL_PATH to fix Murmurhash dependency
    && mv ${SCIDB_SOURCE_PATH}/extern ${SCIDB_INSTALL_PATH} \
    && sudo -u postgres psql -c "ALTER USER "postgres" WITH PASSWORD 'postgres';" \
    && POSTGRES_HOME=$(echo ~postgres) \    
 	  && mkdir -p ${DATA_DIR}/scidb \
    && chown -R ${SCIDB_USR}:${SCIDB_USR} ${DATA_DIR} \
    && chown -R scidb:scidb $SCIDB_INSTALL_PATH \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf ${DEV_DIR}

# ##############################################################################
RUN echo 'scidb ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

# ##############################################################################
COPY files/create_scidb_cluster.sh /usr/local/bin
RUN  chmod +x /usr/local/bin/create_scidb_cluster.sh

COPY files/docker-entrypoint.sh /
RUN  chmod +x /docker-entrypoint.sh

WORKDIR /home/${SCIDB_USR}
USER scidb

ENTRYPOINT  /docker-entrypoint.sh
