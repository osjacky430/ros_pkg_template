#!/usr/bin/env bash
set -eou pipefail

PYTHON_VERSION="3.9.13"

apt-get install -y --no-install-recommends zlib1g-dev libssl-dev

cd /opt/
wget -nv -O Python-$PYTHON_VERSION.tgz https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz  -o /dev/null
tar xzf Python-$PYTHON_VERSION.tgz

cd Python-$PYTHON_VERSION
./configure --enable-optimizations
make altinstall

update-alternatives --install /usr/bin/python3 python3 $(which python3.9) 100
ln -s /usr/share/pyshared/lsb_release.py /usr/local/lib/python3.9/site-packages/lsb_release.py
rm /opt/Python-$PYTHON_VERSION.tgz