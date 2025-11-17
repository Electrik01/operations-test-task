#!/bin/bash
set -e

until pg_isready -h postgres_primary -p 5432 -U postgres; do
  echo "postgres_primary:5432 - no response"
  echo "Waiting for primary..."
  sleep 2
done

if [ -z "$(ls -A "$PGDATA" 2>/dev/null)" ]; then
  echo "Starting base backup from primary..."
  export PGPASSWORD='123123'
  pg_basebackup -h postgres_primary \
                -D "$PGDATA" \
                -U replicator \
                -Fp -Xs -P -R
  echo "Base backup completed."
fi

exec docker-entrypoint.sh postgres
