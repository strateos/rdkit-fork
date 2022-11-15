# A build environment for RDKit Java wrapper and PostgreSQL cartridge.
#
# How to build: docker build --rm --tag strateos/rdkit-build-env --file Scripts/RDKitBuilder.Dockerfile ./
# How to run: docker run -it  --volume .:/rdkit  --workdir /rdkit strateos/rdkit-build-env make -C Scripts -f Makefile.strateos boost inchi

FROM registry.hub.docker.com/library/ubuntu:20.04
#FROM registry.hub.docker.com/library/ubuntu:22.04

# Used Gradle version to publish artifacts
ARG GRADLE_VERSION=7.5.1

# Major version for installed openjdk
ARG JAVA_VERSION=17

# Major version for Postgresql to build RDKit cartridge
ARG PG_VERSION_MAJOR=12

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      cmake \
      curl \
      git \
      libeigen3-dev \
      libfreetype6-dev \
      openjdk-${JAVA_VERSION}-jdk \      
      postgresql-server-dev-${PG_VERSION_MAJOR} \
      swig3.0 \
      unzip \
      zip \
      zlib1g-dev

RUN curl -L -o /tmp/gradle-${GRADLE_VERSION}-bin.zip \
      https://downloads.gradle-dn.com/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && mkdir -p /usr/lib/gradle \
    && unzip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /usr/lib/gradle \
    && update-alternatives --install /usr/bin/gradle gradle /usr/lib/gradle/gradle-${GRADLE_VERSION}/bin/gradle 1117

ENV JAVA_VERSION=${JAVA_VERSION}
ENV PG_VERSION_MAJOR=${PG_VERSION_MAJOR}
