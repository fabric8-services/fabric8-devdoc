#!/usr/bin/env bash

# Show all command prior to executing them
set -x

# Exit if a command fails
set -e

# Create user with same UID and name as the user that
# started the container
echo "Creating new user \"$USER\" with UID \"$USERID\""
useradd -m ${USER} -u ${USERID}

# Where the source is stored?
# Take the value of the first and second argument or default
# to /source and /build
source_dir=${1:-/source}
build_dir=${2:-/build}

# Give all rights to users outside of the container
function almighty_clean_up {
  chown -R $USER ${build_dir} 
}
trap 'echo "SIGNAL received. Will clean up."; almighty_clean_up' SIGUSR1 SIGTERM SIGINT EXIT

su $USER --command=" \
cd ${source_dir} \
&& cp -Rfp . ${build_dir} \
&& chown -Rf $USER ${build_dir} \
&& source /etc/profile.d/rvm.sh \
&& cd ${build_dir} \
&& bundle install --path=${build_dir}/bundle-install \
&& bundle exec jekyll build \
"

