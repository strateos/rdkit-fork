#!/bin/bash

set -e

cmake -Wno-dev \
    # General configuration \
    -DBoost_USE_STATIC_LIBS=ON \
    -DRDK_BUILD_INCHI_SUPPORT=ON \
    -DRDK_BUILD_AVALON_SUPPORT=OFF \
    -DRDK_BUILD_PYTHON_WRAPPERS=OFF \
    # PostgreSQL cartridge
    -DRDK_BUILD_PGSQL=ON \
    -DRDK_PGSQL_STATIC=ON \
    -DPostgreSQL_VERSION_STRING=$POSTGRESQL_VERSION \
    -DPostgreSQL_ROOT=/usr/lib/postgresql/$POSTGRESQL_VERSION \
    -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/$POSTGRESQL_VERSION/server \
    -DPostgreSQL_LIBRARY=/usr/lib/postgresql/$POSTGRESQL_VERSION/lib \
    -DPostgreSQL_INCLUDE_DIR=/usr/include/postgresql/$POSTGRESQL_VERSION \
    # Java wrappers
    -DRDK_BUILD_SWIG_WRAPPERS=ON \
    -DRDK_BUILD_SWIG_JAVA_WRAPPER=ON \
    ..
