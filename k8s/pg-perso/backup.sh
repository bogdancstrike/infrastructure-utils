#!/bin/bash
set -e

TMP_OUT=/tmp/dump.sql

Help() {
    echo "Takes a backup of all PostgreSQL databases using pg_dumpall."
    echo
    echo "PGPASSWORD should be set via environment variable"
    echo "ENCRYPT_PASSWORD should be set via environment variable"
    echo
    echo "syntax ./backup.sh -H postgres_host:port -u database_user -o /path/to/output/directory/"
    echo
    echo args:
    echo "h     Displays this help message."
    echo "H     The host:port at which to reach the postgres server."
    echo "u     The database user to use. ENCRYPT_PASSWORD must be set."
    echo "o     The directory to write the backup to. Backup file will be named in YYYY-MM-DD-all-databases.sql.gz.enc"
    echo "C     (Optional) The path to the SSL certificate file."
    echo "K     (Optional) The path to the SSL key file."
    echo "R     (Optional) The path to the SSL root certificate file."
    echo "M     (Optional) The SSL mode (e.g., verify-ca)."
}

Die() {
    echo >&2 "$@"
    echo
    Help
    echo
    exit 1
}

ParseArgs() {
    while getopts "h:H:u:o:C:K:R:M:" option; do
       case $option in
            h) # display Help
                Help
                exit;;
            H)
                DB_HOST_PORT=${OPTARG};;
            u)
                DB_USER=${OPTARG};;
            o)
                OUT_DIR=${OPTARG};;
            C)
                SSL_CERT=${OPTARG};;
            K)
                SSL_KEY=${OPTARG};;
            R)
                SSL_ROOT_CERT=${OPTARG};;
            M)
                SSL_MODE=${OPTARG};;
            \?) # Invalid option
                echo "Error: Invalid option"
                Help
                exit;;
       esac
    done
}

ValidateArgs() {
    ! [[ -z ${DB_HOST_PORT} ]] || Die "missing required arg -H"
    ! [[ -z ${DB_USER} ]] || Die "missing required arg -u"
    ! [[ -z ${OUT_DIR} ]] || Die "missing required arg -o"
    ! [[ -z ${PGPASSWORD} ]] || Die "PGPASSWORD env var must be set"
    ! [[ -z ${ENCRYPT_PASSWORD} ]] || Die "ENCRYPT_PASSWORD env var must be set"
}

DumpDBAll() {
    # Split DB_HOST_PORT into host and port
    DB_HOST=$(echo ${DB_HOST_PORT} | cut -d':' -f1)
    DB_PORT=$(echo ${DB_HOST_PORT} | cut -d':' -f2)

    # Build the connection string
    CONN_STR="host=${DB_HOST} port=${DB_PORT} user=${DB_USER}"

    # Optionally append SSL parameters if provided
    [[ ! -z ${SSL_CERT} ]] && CONN_STR+=" sslcert=${SSL_CERT}"
    [[ ! -z ${SSL_KEY} ]] && CONN_STR+=" sslkey=${SSL_KEY}"
    [[ ! -z ${SSL_ROOT_CERT} ]] && CONN_STR+=" sslrootcert=${SSL_ROOT_CERT}"
    [[ ! -z ${SSL_MODE} ]] && CONN_STR+=" sslmode=${SSL_MODE}"

    # Run pg_dumpall with connection string
    echo "${CONN_STR}"
    pg_dumpall -d "${CONN_STR}" -f ${TMP_OUT}
}

EncryptDump() {
    mkdir -p ${OUT_DIR}
    gzip -c ${TMP_OUT} \
        |  openssl enc -pbkdf2 \
              -salt \
              -out ${OUT_DIR}/$(date +%F)-all-databases.sql.gz.enc \
              -pass pass:${ENCRYPT_PASSWORD}
}

ParseArgs $@
ValidateArgs
DumpDBAll
EncryptDump
