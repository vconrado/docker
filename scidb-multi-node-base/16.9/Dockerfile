FROM ubuntu:14.04
LABEL maintainer="e-sensing team <esensing-team@dpi.inpe.br>"

# ##############################################################################
# Exporting SCIDB Port to be able to access through host machine

# ##############################################################################
# Configuration variables
ENV SCIDB_USR=scidb
ENV SCIDB_PASS=scidb


# ##############################################################################
# Creating scidb user
RUN groupadd $SCIDB_USR \
    && useradd $SCIDB_USR -s /bin/bash -m -g $SCIDB_USR \
    && echo $SCIDB_USR:$SCIDB_PASS | chpasswd  \
    && chmod g-w /home/$SCIDB_USR

# ##############################################################################
# Instaling dependencies
RUN apt-get update && \
    apt-get install -y wget \
		       apt-transport-https \
		       software-properties-common \
		       expect \
		       openssh-server \
		       openssh-client \
		       vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# SSH passwordless
RUN service ssh start && \
    ssh-keygen -f /root/.ssh/id_rsa -N '' && \
    # Pre-instalation tasks
    mkdir /home/$SCIDB_USR/.ssh && \
    ssh-keygen -f /home/$SCIDB_USR/.ssh/id_rsa -N '' && \
    chmod go-rwx /home/$SCIDB_USR/.ssh && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
    cat /root/.ssh/id_rsa.pub >> /home/$SCIDB_USR/.ssh/authorized_keys && \
    cat /home/${SCIDB_USR}/.ssh/id_rsa.pub >> /home/$SCIDB_USR/.ssh/authorized_keys && \
    cat /home/${SCIDB_USR}/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
    chown -R $SCIDB_USR:$SCIDB_USR /home/$SCIDB_USR && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    #ssh ${SCIDB_USR}@localhost date && \
    #ssh root@localhost date
