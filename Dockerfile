FROM jupyter/minimal-notebook

USER root

#The trick in this Dockerfile is to change the ownership of /run/postgresql
RUN  apt-get update && \
    apt-get install -qq -y \
        libpq-dev postgresql postgresql-client postgis && apt-get clean && \
    chown jovyan /run/postgresql/




USER jovyan

COPY *.ipynb ./

RUN conda install -c conda-forge geopandas matplotlib intake
RUN pip install intake-dcat intake_geopandas

RUN wget https://earthquake.usgs.gov/static/lfs/nshm/qfaults/Qfaults_2018_shapefile.zip
RUN unzip Qfaults_2018_shapefile.zip && rm Qfaults_2018_shapefile.zip

RUN pip install psycopg2

ENV JUPYTER_ENABLE_LAB=1

USER root
COPY ./entrypoint.sh  /
RUN chmod +x /entrypoint.sh
USER jovyan

ENTRYPOINT ["/entrypoint.sh"]
