#!/bin/bash

set -e

dockerize -wait tcp://${SENTRY_POSTGRES_HOST:-postgres}:${SENTRY_POSTGRES_PORT:-5432} -wait tcp://${SENTRY_REDIS_HOST:-redis}:${SENTRY_REDIS_PORT:-6379} -timeout 30s

if ! [ -z ${SENTRY_MEMCACHED_HOST+x} ]; then 
	dockerize -wait tcp://${SENTRY_MEMCACHED_HOST:-memcached}:${SENTRY_MEMCACHED_PORT:-11211} -timeout 30s;
fi

if ! [ -z ${SENTRY_CASSANDRA_HOST+x} ]; then 
	dockerize -wait tcp://${SENTRY_CASSANDRA_HOST:-cassandra}:${SENTRY_CASSANDRA_PORT:-9042} -timeout 30s;
fi


# first check if we're passing flags, if so
# prepend with sentry
if [ "${1:0:1}" = '-' ]; then
	set -- sentry "$@"
fi

case "$1" in
	celery|cleanup|config|createuser|devserver|django|export|help|import|init|plugins|queues|repair|run|shell|start|tsdb|upgrade)
		set -- sentry "$@"
	;;
	generate-secret-key)
		set -- sentry config generate-secret-key
	;;
esac

if [ "$1" = 'sentry' ]; then
	set -- tini -- "$@"
	if [ "$(id -u)" = '0' ]; then
		mkdir -p "$SENTRY_FILESTORE_DIR"
		chown -R sentry "$SENTRY_FILESTORE_DIR"
		set -- gosu sentry "$@"
	fi
fi

exec "$@"
