FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update  \
    && apt install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      cmake \
      curl \
      git \
      zlib1g-dev \
    && apt-get clean -y

ARG BOOST_URL=https://boostorg.jfrog.io/artifactory/main/release/1.80.0/source/boost_1_80_0.tar.bz2
ARG BOOST_ARCHIVE=boost_1_80_0.tar.bz2
ARG BOOST_SOURCE_DIR=boost_1_80_0
RUN curl -L -o $BOOST_ARCHIVE $BOOST_URL \
    && tar --bzip2 -xf $BOOST_ARCHIVE \
    && cd $BOOST_SOURCE_DIR \
    && chmod +x ./bootstrap.sh  \
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

ARG POSTGRESQL_VERSION=14
ARG JAVA_VERSION=17

RUN apt update \
      && apt install -y --no-install-recommends  \
        gnupg \
        lsb-release \
      && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
      && echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt update  \
      && apt install -y --no-install-recommends  \
        swig3.0 \
        libeigen3-dev \
        libfreetype6-dev \
        openjdk-${JAVA_VERSION}-jdk \
        postgresql-$POSTGRESQL_VERSION \
        postgresql-server-dev-$POSTGRESQL_VERSION \
    && apt-get clean -y

ARG TARGETARCH
ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-${TARGETARCH}
ENV RDKIT_DIR=/rdkit

WORKDIR $RDKIT_DIR/build

RUN ls -lh

RUN cmake -Wno-dev \
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

RUN make -j $(nproc) \
    && make install