#!/bin/bash
# Runs only when the official PostgreSQL image initializes an empty data directory.
set -euo pipefail

create_user_and_database() {
    local database="$1"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres \
        --set=database="$database" --set=owner="$POSTGRES_USER" <<'EOSQL'
SELECT format('CREATE ROLE %I LOGIN', :'database')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'database')\gexec
SELECT format('CREATE DATABASE %I OWNER %I', :'database', :'owner')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'database')\gexec
GRANT ALL PRIVILEGES ON DATABASE :"database" TO :"database";
GRANT ALL PRIVILEGES ON DATABASE :"database" TO :"owner";
EOSQL

    # Use a separate connection: psql meta-command arguments do not accept SQL semicolons.
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$database" \
        --set=schema="${SCHEMA:-public}" --set=owner="$POSTGRES_USER" <<'EOSQL'
CREATE SCHEMA IF NOT EXISTS :"schema" AUTHORIZATION :"owner";
GRANT ALL PRIVILEGES ON SCHEMA :"schema" TO :"owner";
EOSQL
}

IFS=',' read -r -a databases <<< "${POSTGRES_MULTIPLE_DATABASES:-}"
for database in "${databases[@]}"; do
    if [[ -n "$database" ]]; then
        create_user_and_database "$database"
    fi
done
