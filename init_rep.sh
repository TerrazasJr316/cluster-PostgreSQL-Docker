#!/bin/bash

# Asegurar permisos correctos en el volumen
chown -R postgres:postgres /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data

# Si la base de datos está vacía, iniciar clonación
if [ ! -s /var/lib/postgresql/data/PG_VERSION ]; then
  rm -rf /var/lib/postgresql/data/*
  
  # Bucle de reintento en caso de desconexión del maestro
  until PGPASSWORD=${REPLICA_PASSWORD} gosu postgres pg_basebackup -h pg_primary -U ${REPLICA_USER} -D /var/lib/postgresql/data -R -X stream -c fast; do
    echo 'Fallo en la copia, limpiando basura y reintentando...'
    rm -rf /var/lib/postgresql/data/*
    sleep 3
  done
fi

# Entregar el control al script original de arranque de Postgres
exec docker-entrypoint.sh postgres