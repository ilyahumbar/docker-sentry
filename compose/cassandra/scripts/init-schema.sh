#!/usr/bin/env bash

# Orchestrate the automatic execution of all the cql migration scripts when starting the cluster

# Protect from iterating on empty directories
shopt -s nullglob

function log {
    echo "[$(date)]: $*"
}

function logDebug {
    ((DEBUG_LOG)) && echo "[DEBUG][$(date)]: $*"
}

function waitForClusterConnection() {
    log "waiting for cassandra connection..."
    retryCount=0
    maxRetry=20
    cqlsh -e "Describe KEYSPACES;" $CASSANDRA_CONTACT_POINT &>/dev/null
    while [ $? -ne 0 ] && [ "$retryCount" -ne "$maxRetry" ]; do
        logDebug 'cassandra not reachable yet. sleep and retry. retryCount =' $retryCount
        sleep 5
        ((retryCount+=1))
        cqlsh -e "Describe KEYSPACES;" $CASSANDRA_CONTACT_POINT &>/dev/null
    done

    if [ $? -ne 0 ]; then
      log "not connected after " $retryCount " retry. Abort the migration."
      exit 1
    fi

    log "connected to cassandra cluster"
}

waitForClusterConnection

log "execute cassandra setup script"

log "use $CREATE_KEYSPACE_SCRIPT script to create keyspace if necessary"
cqlsh -f /cql/$CREATE_KEYSPACE_SCRIPT $CASSANDRA_CONTACT_POINT

log "cassandra init done"
