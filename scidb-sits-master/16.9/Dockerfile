FROM terrama2.dpi.inpe.br:443/scidb-sits:16.9
LABEL maintainer="e-sensing team <esensing-team@dpi.inpe.br>"

ADD files/scidb-16.9.0.db1a98f.tgz /home/scidb/Devel/scidb-16.9

COPY files/limpa_dirs.sh  /home/scidb/Devel/scripts/
COPY files/prepare_dirs.sh  /home/scidb/Devel/scripts/
COPY files/prepare_hosts.sh  /home/scidb/Devel/scripts/

COPY files/docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT  /docker-entrypoint.sh
