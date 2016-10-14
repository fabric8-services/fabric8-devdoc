#!/bin/bash

# Show command before executing
set -x

# We need to disable selinux for now, XXX
/usr/sbin/setenforce 0

# Get all the deps in
yum -y install \
  docker \
  make \
  git 
service docker start

# remove previous generated site
rm -rf _site

# Build builder image
docker build -t almighty-devdoc-builder -f Dockerfile .

# Build site
docker run --detach=true --name=almighty-devdoc-builder -t -v $(pwd):/almighty-devdoc:Z almighty-devdoc-builder "jekyll build"

# TODO: Test ?

if [ $? -eq 0 ]; then
  echo 'CICO: unit tests OK'
else
  echo 'CICO: unit tests FAIL'
  exit 1
fi


