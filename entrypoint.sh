#!/bin/bash
set -e

PGDATA=${PGDATA:-/home/jovyan/srv/pgsql}

if [ ! -d "$PGDATA" ]; then
  /usr/lib/postgresql/10/bin/initdb -D "$PGDATA" --auth-host=md5 --encoding=UTF8
fi
/usr/lib/postgresql/10/bin/pg_ctl -D "$PGDATA" status || /usr/lib/postgresql/10/bin/pg_ctl -D "$PGDATA" -l "$PGDATA/pg.log" start

psql postgres -c "CREATE USER test PASSWORD 'testpass'"
createdb -O test test
psql test -c "CREATE EXTENSION postgis"

#ogr2ogr -f PostgreSQL PG:"dbname='test' user='test' password='testpass' port='5432' host='localhost'" \
#  -lco OVERWRITE=yes --config PG_USE_COPY YES Qfaults_2018_shapefile 

exec "$@"
