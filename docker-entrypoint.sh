#!/bin/bash

# Run Elasticsearch and allow setting default settings via env vars
#
# e.g. Setting the env var cluster.name=testcluster
#
# will cause Elasticsearch to be invoked with -Ecluster.name=testcluster
#
# see https://www.elastic.co/guide/en/elasticsearch/reference/5.0/settings.html#_setting_default_settings

set -e

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@"
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data

	set -- su-exec elasticsearch "$@"
	#exec gosu elasticsearch "$BASH_SOURCE" "$@"
fi

# Copied Environment Vairables logic from https://github.com/elastic/elasticsearch-docker/blob/master/build/elasticsearch/bin/es-docker
es_opts=''

while IFS='=' read -r envvar_key envvar_value
do
    # Elasticsearch env vars need to have at least two dot separated lowercase words, e.g. `cluster.name`
    if [[ "$envvar_key" =~ ^[a-z]+\.[a-z]+ ]]
    then
        if [[ ! -z $envvar_value ]]; then
          es_opt="-E${envvar_key}=${envvar_value}"
          es_opts+=" ${es_opt}"
        fi
    fi
done < <(env)

if [ -f /sys/hypervisor/uuid ] && [ `head -c 3 /sys/hypervisor/uuid` == ec2 ]; then
  AWS_PRIVATE_IP=$(wget -qO- http://169.254.169.254/latest/meta-data/local-ipv4)
  AWS_PRIVATE_HOSTNAME=$(wget -qO- http://169.254.169.254/latest/meta-data/local-hostname)
  set -- "$@" ${es_opts} -Enetwork.publish_host=$AWS_PRIVATE_IP -Enode.name=$AWS_PRIVATE_HOSTNAME
else
  set -- "$@" ${es_opts}
fi

exec "$@"
