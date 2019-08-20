FROM jupyter/minimal-notebook

USER root
#The trick in this Dockerfile is to change the ownership of /run/postgresql
RUN apt-get update && \
    apt-get install -qq -y \
        libpq-dev postgresql postgresql-client postgis && apt-get clean && \
    chown jovyan /run/postgresql/
USER jovyan

# Make some python installs
RUN conda install -c conda-forge geopandas matplotlib intake cartopy
RUN pip install intake-dcat intake_geopandas psycopg2 geoalchemy2
RUN pip install git+https://github.com/ian-r-rose/ibis.git@eec61a6
RUN pip install git+https://github.com/intake/intake-sql@fc07c7a

# Set up sample data
COPY data/Qfaults_2018_shapefile.zip ./
RUN unzip Qfaults_2018_shapefile.zip && rm Qfaults_2018_shapefile.zip
COPY data/earthquakes.geojson ./

ENV JUPYTER_ENABLE_LAB=1

# Set up the entrypoint
USER root
COPY ./binder/entrypoint.sh  /
RUN chmod +x /entrypoint.sh
USER jovyan

# Copy demo notebooks
COPY postgis-ibis-geopandas.ipynb ./
COPY catalog.yml ./
RUN fix-permissions ./
RUN rmdir ./work

ENTRYPOINT ["/entrypoint.sh"]
