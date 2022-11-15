#!/bin/bash
# Install system level dependencies to build RDKit

# Major version for installed openjdk
JAVA_VERSION="${JAVA_VERSION:-17}"     

set -e

PACKAGES=(
      build-essential
      ca-certificates
      cmake
      curl
      git
      openjdk-${JAVA_VERSION}-jdk # build requirement: RDKit java wrapper      
      swig3.0 # build requirement: RDKit java wrapper
      libeigen3-dev
      libfreetype6-dev
      postgresql-server-dev-12
      unzip
      zip
      zlib1g-dev
)

# Is here sudo or not?
command -v sudo && PKGM_CMD="sudo apt-get" || PKGM_CMD="apt-get"
export DEBIAN_FRONTEND=noninteractive
${PKGM_CMD} update && ${PKGM_CMD} install -y --no-install-recommends "${PACKAGES[@]}"
