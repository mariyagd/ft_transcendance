FROM debian:bullseye-slim

# Specifies the path for postgresql binary
ENV PATH="/usr/lib/postgresql/13/bin/:$PATH"

# Specifies where database willbe stored
ENV PGDATA="/var/lib/postgresql/data"

# Specifies whether to use color in diagnostic messages.
ENV PG_COLOR="always"

# Specifies the default time zone of the created database cluster
ENV TZ="Europe/Zurich"

# postgresql installation creates automatically a superuser "postgres"
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y postgresql \
                   iputils-ping # for ping test

RUN mkdir -p /etc/postgresql && \
    mkdir -p /etc/postgresql/sql_scripts

COPY conf/postgresql.conf /etc/postgresql/postgresql.conf
COPY scripts/initdb.sh ./

RUN chmod +x initdb.sh

USER postgres

EXPOSE 5432

CMD ["./initdb.sh"]
