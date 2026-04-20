#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER $REPLICA_USER WITH REPLICATION ENCRYPTED PASSWORD '$REPLICA_PASSWORD';
    -- Slot para la primera réplica
    SELECT * FROM pg_create_physical_replication_slot('replication_slot_1');
    -- Slot para la segunda réplica
    SELECT * FROM pg_create_physical_replication_slot('replication_slot_2');
EOSQL

echo "host replication $REPLICA_USER 0.0.0.0/0 scram-sha-256" >> "$PGDATA/pg_hba.conf"