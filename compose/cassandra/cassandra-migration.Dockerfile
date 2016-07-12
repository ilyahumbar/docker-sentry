FROM cassandra:2.2.5

# script to orchestrate the automatic keyspace creation and apply all migration scripts
ADD scripts/init-schema.sh /usr/local/bin/init-schema
RUN chmod 755 /usr/local/bin/init-schema

ENTRYPOINT ["init-schema"]
