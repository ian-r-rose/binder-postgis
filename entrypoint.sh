#!/bin/bash
set -e

# Set the location for the data
PGDATA=${PGDATA:-/home/jovyan/srv/pgsql}

# Launch the postgresql server
if [ ! -d "$PGDATA" ]; then
  /usr/lib/postgresql/10/bin/initdb -D "$PGDATA" --auth-host=md5 --encoding=UTF8
fi
/usr/lib/postgresql/10/bin/pg_ctl -D "$PGDATA" status || /usr/lib/postgresql/10/bin/pg_ctl -D "$PGDATA" -l "$PGDATA/pg.log" start

# Creat a test database and user with PostGIS.
# We needt to specify the right psql, as conda also installs one
# that shadows the system one.
/usr/bin/psql postgres -c "CREATE USER test PASSWORD 'testpass'"
/usr/bin/createdb -O test test
/usr/bin/psql test -c "CREATE EXTENSION postgis"

# Load the shapefile into the database
ogr2ogr -f PostgreSQL PG:"dbname='test' user='test' password='testpass' port='5432' host='localhost'" \
  --debug on \
  -where "OGR_GEOMETRY='LineString' or OGR_GEOMETRY='MultiLineString'" \
  -lco OVERWRITE=yes \
  -lco precision=NO \
  -nlt PROMOTE_TO_MULTI \
  -nln faults \
  --config PG_USE_COPY YES \
  Qfaults_2018_shapefile
rm -rf Qfaults_2018_shapefile

# Launch the notebook server
exec "$@"
