#!/bin/bash

set -e

sudo apt update \
      && sudo apt install -y --no-install-recommends  \
        gnupg \
        lsb-release \
      && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
      && echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list \
    && sudo apt update  \
      && sudo apt install -y --no-install-recommends  \
        swig3.0 \
        libeigen3-dev \
        libfreetype6-dev \
        openjdk-${JAVA_VERSION}-jdk \
        postgresql-$POSTGRESQL_VERSION \
        postgresql-server-dev-$POSTGRESQL_VERSION \
    && sudo apt-get clean -y

echo $JAVA_HOME

export RDKIT_DIR=/rdkit

