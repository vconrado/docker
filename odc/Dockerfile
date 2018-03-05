FROM ubuntu:16.04
LABEL maintainer="Vitor Gomes <vconrado@gmail.com>"

VOLUME /datacube


EXPOSE 5432
EXPOSE 80


ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN apt-get update \
	&& apt-get -y install sudo vim git curl postgresql-9.5 postgresql-client-9.5 postgresql-contrib-9.5 libhdf5-serial-dev libnetcdf-dev libgdal1-dev hdf5-tools netcdf-bin gdal-bin python3-pip\
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd datacube \
	&& useradd datacube -s /bin/bash -m -g datacube \
	&& echo datacube:datacube| chpasswd \
	&& usermod -a -G sudo datacube \
	&& chown -R datacube:datacube /home/datacube \
        && echo 'datacube ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

USER datacube

RUN mkdir ~/Datacube \
	&& cd ~/Datacube \
	&& git clone https://github.com/ceos-seo/agdc-v2.git -b master \
	&& git clone https://github.com/ceos-seo/data_cube_ui.git -b master \
	&& git clone https://github.com/ceos-seo/data_cube_notebooks.git -b master \
	&& cd ~/Datacube/data_cube_ui \
	&& git submodule init && git submodule update \
	&& cd ~/Datacube/data_cube_notebooks \
	&& git submodule init && git submodule update \
	&& cp ~/Datacube/data_cube_ui/config/.datacube.conf ~/.datacube.conf

RUN sudo mkdir -p /datacube/{original_data,ingested_data} \
	&& sudo chmod -R 777 /datacube/ \
	&& sudo pip3 install virtualenv

RUN	/bin/bash -c "virtualenv ~/Datacube/datacube_env; \
	 	source ~/Datacube/datacube_env/bin/activate; \
		pip install numpy; \
		pip install --global-option=build_ext --global-option=\"-I/usr/include/gdal\" gdal==1.11.2; \
		pip install shapely scipy cloudpickle Cython netcdf4; \
		cd ~/Datacube/agdc-v2; \
		python setup.py develop; \
		rm -rf ~/.cache/pip"

COPY files/pg_hba.conf /etc/postgresql/9.5/main/pg_hba.conf
COPY files/postgresql.conf /etc/postgresql/9.5/main/postgresql.conf

RUN sudo service postgresql restart \
	&& sudo -u postgres createuser --superuser dc_user \
	&& sudo -u postgres psql -c "ALTER USER dc_user WITH PASSWORD 'localuser1234';" \
	&& export PGPASSWORD=localuser1234 \
	&&  createdb -U dc_user datacube \
	&& printf "export LC_ALL=C.UTF-8 \nexport LANG=C.UTF-8" | sudo tee -a  /etc/bash.bashrc \
	&& export LC_ALL=C.UTF-8 \
	&& export LANG=C.UTF-8 \
	&& /bin/bash -c "source ~/Datacube/datacube_env/bin/activate; datacube -v system init"



COPY files/entrypoint.sh /

WORKDIR /home/datacube
USER datacube


ENTRYPOINT  /entrypoint.sh

