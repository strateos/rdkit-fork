#!/bin/bash

set -e

sudo apt update  \
    && sudo apt install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      cmake \
      curl \
      git \
      zlib1g-dev \
    && sudo apt-get clean -y

export BOOST_URL=https://boostorg.jfrog.io/artifactory/main/release/1.80.0/source/boost_1_80_0.tar.bz2

export BOOST_ARCHIVE=boost_1_80_0.tar.bz2

export BOOST_SOURCE_DIR=boost_1_80_0

curl -L -o $BOOST_ARCHIVE $BOOST_URL \
    && tar --bzip2 -xf $BOOST_ARCHIVE \
    && cd $BOOST_SOURCE_DIR \
    && sudo chmod +x ./bootstrap.sh  \
    && ./bootstrap.sh \
      --with-libraries=system \
      --with-libraries=thread \
      --with-libraries=iostreams \
      --with-libraries=regex \
      --with-libraries=serialization \
    && ./b2  \
      cflags=-fPIC \
      cxxflags=-fPIC \
      link=static \
      --prefix=/usr \
      -j $(nproc) \
      install \
    && cd / \
    && rm $BOOST_ARCHIVE \
    && rm -r $BOOST_SOURCE_DIR

export POSTGRESQL_VERSION=14

export ARG JAVA_VERSION=17

