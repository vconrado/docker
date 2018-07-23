FROM ubuntu:14.04
LABEL maintainer="e-sensing team <esensing-team@dpi.inpe.br>"

# ##############################################################################
# Exporting SCIDB port
EXPOSE 1239

ENV SCIDB_USR=scidb
ENV SCIDB_PASS=scidb


RUN apt-get update \
    && apt-get install -y software-properties-common\
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update \
    && apt-get install -y   wget \
                            openssh-client \
                            openssh-server \
                            apt-transport-https \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update \
    && apt-get install -y   g++-4.9 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd $SCIDB_USR \
     && useradd $SCIDB_USR -s /bin/bash -m -g $SCIDB_USR \
     && echo $SCIDB_USR:$SCIDB_PASS | chpasswd  \
     && chmod g+w /home/$SCIDB_USR\
     && chown -R scidb:scidb /home/scidb \
     && chmod -R g+w /home/$SCIDB_USR

RUN echo 'scidb ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

RUN mv /usr/bin/logname /usr/bin/logname.bkp
COPY files/logname /usr/bin/logname

USER scidb
WORKDIR /home/scidb

#RUN wget https://downloads.paradigm4.com/community/18.1/install-scidb-ce.sh 
RUN mkdir /home/scidb/Devel
COPY files/install-scidb-ce.sh /home/scidb/Devel

RUN sudo apt-get update \
    && sudo service ssh start\
    && sudo ./Devel/install-scidb-ce.sh \
    && sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "export SCIDB_VER=18.1 \n\
    export PATH=/opt/scidb/\$SCIDB_VER/bin:/opt/scidb/\$SCIDB_VER/share/scidb:\$PATH" | tee -a ~/.scidbrc \ 
    && echo "source ~/.scidbrc" | tee -a ~/.bashrc


USER root

COPY files/wait_for_postgres.sh /usr/local/bin                                                                                                                                                                                    
RUN chmod +rx /usr/local/bin/wait_for_postgres.sh

COPY files/docker-entrypoint.sh /usr/local/bin
RUN  chmod +rx /usr/local/bin/docker-entrypoint.sh

USER scidb
WORKDIR /home/scidb

ENTRYPOINT  /usr/local/bin/docker-entrypoint.sh                                                                                                                                                                                                 
