#!/bin/bash -i

# Fail on errors.
# set -im

# Make sure .bashrc is sourced
. /root/.bashrc

# Allow the workdir to be set using an env var.
# Useful for CI pipiles which use docker for their build steps
# and don't allow that much flexibility to mount volumes
SRCDIR=$1

PYPI_URL=$2

PYPI_INDEX_URL=$3

WORKDIR=${SRCDIR:-/src}

SPEC_FILE=${4:-*.spec}

/root/.pyenv/shims/python -m pip install --upgrade pip wheel setuptools

cd $WORKDIR

apt-get install -y build-essential pkg-config cargo rustc

if [ -f $6 ]; then
    /root/.pyenv/shims/pip install -r $6
fi # [ -f $6 ]

apt-get update
apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
apt-get install -y libglib2.0-0
apt-get install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-webkit2-4.0 python3-wheel python3-dev
apt-get install -y libgirepository1.0-dev build-essential libbz2-dev libreadline-dev libssl-dev zlib1g-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libcairo2-dev binutils

/root/.pyenv/shims/pip install PyGObject

/root/.pyenv/shims/pyinstaller --clean -y --dist ./dist/linux --workpath /tmp $SPEC_FILE

chown -R --reference=. ./dist/linux
