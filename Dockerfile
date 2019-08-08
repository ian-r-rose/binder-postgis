FROM jupyter/minimal-notebook

USER root
#The trick in this Dockerfile is to change the ownership of /run/postgresql
RUN apt-get update && \
    apt-get install -qq -y \
        libpq-dev postgresql postgresql-client postgis && apt-get clean && \
    chown jovyan /run/postgresql/
USER jovyan

# Make some python installs
RUN conda install -c conda-forge geopandas matplotlib intake
RUN pip install intake-dcat intake_geopandas psycopg2
RUN pip install git+https://github.com/ibis-project/ibis.git@8bb84bb

# Download sample data
RUN wget https://earthquake.usgs.gov/static/lfs/nshm/qfaults/Qfaults_2018_shapefile.zip
RUN unzip Qfaults_2018_shapefile.zip && rm Qfaults_2018_shapefile.zip

ENV JUPYTER_ENABLE_LAB=1

# Set up the entrypoint
USER root
COPY ./entrypoint.sh  /
RUN chmod +x /entrypoint.sh
USER jovyan

# Copy demo notebooks
COPY demo.ipynb ./
COPY catalog.yml ./
RUN rmdir ./work

ENTRYPOINT ["/entrypoint.sh"]
