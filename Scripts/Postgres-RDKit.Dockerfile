# Postgresql image with rdkit for development needs.
#
# How to build: docker build --rm --squash --tag strateos/postgres-rdkit --file Scripts/Postgres-RDKit.Dockerfile ./
# How to run: docker run -d strateos/postgres-rdkit

ARG PG_VERSION_MAJOR=12

FROM registry.hub.docker.com/library/postgres:${PG_VERSION_MAJOR}-bullseye

ARG PG_VERSION_MAJOR=12

RUN apt-get update \
    && apt-get install -y --no-install-recommends libfreetype6

#COPY Code/PgSQL/rdkit/rdkit-*.sql Code/PgSQL/rdkit/update_sql/*.sql Code/PgSQL/rdkit/rdkit.control /tmp/extension/
#COPY Code/PgSQL/rdkit/librdkit.so /tmp/lib/rdkit.so
COPY postgresql-${PG_VERSION_MAJOR}-rdkit-strateos.deb /tmp/postgresql-rdkit-strateos.deb

#RUN mv -t $(pg_config --sharedir) /tmp/extension/* \
#    && mv -t $(pg_config --pkglibdir) /tmp/lib/* \
#    && rm -rf /tmp/extension /tmp/lib

RUN dpkg -i /tmp/postgresql-rdkit-strateos.deb