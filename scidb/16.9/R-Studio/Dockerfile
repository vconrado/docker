FROM eows-example
LABEL maintainer="e-sensing team <esensing-team@dpi.inpe.br>"

RUN apt-get update \
    && apt-get install gdebi-core -y \
    && wget https://download2.rstudio.org/rstudio-server-1.1.383-amd64.deb \
    && yes | gdebi rstudio-server-1.1.383-amd64.deb \
    && rm rstudio-server-1.1.383-amd64.deb

EXPOSE 8787

COPY files/entrypoint.sh /

ENTRYPOINT /entrypoint.sh

