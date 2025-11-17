FROM postgres:16

RUN apt-get update && \
    apt-get install -y postgresql-16-cron && \
    rm -rf /var/lib/apt/lists/*

RUN echo "shared_preload_libraries = 'pg_cron'" >> /usr/share/postgresql/postgresql.conf.sample \
 && echo "cron.database_name = 'operations_db'" >> /usr/share/postgresql/postgresql.conf.sample

RUN echo "listen_addresses = '*'" >> /usr/share/postgresql/postgresql.conf.sample \
 && echo "wal_level = replica" >> /usr/share/postgresql/postgresql.conf.sample \
 && echo "max_wal_senders = 10" >> /usr/share/postgresql/postgresql.conf.sample \
 && echo "max_replication_slots = 10" >> /usr/share/postgresql/postgresql.conf.sample \
 && echo "hot_standby = on" >> /usr/share/postgresql/postgresql.conf.sample

ENV POSTGRES_DB=operations_db
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres

COPY init_main/ /docker-entrypoint-initdb.d/

COPY init_replica/replica-entrypoint.sh /usr/local/bin/replica-entrypoint.sh
RUN chmod +x /usr/local/bin/replica-entrypoint.sh
