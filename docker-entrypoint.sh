#!/bin/bash
set -e

if [[ -n $MYSTRENGTH_ENV_BUCKET  ]] && [[ -n $DOWNLOAD_SSL_CERTS ]]; then
  echo "Copying SSL Certs $DOWNLOAD_SSL_CERTS from $MYSTRENGTH_ENV..."
  aws s3 cp s3://$MYSTRENGTH_ENV_BUCKET/ssl/$(echo $DOWNLOAD_SSL_CERTS | tr [A-Z] [a-z]).crt /etc/nginx/certs/
  aws s3 cp s3://$MYSTRENGTH_ENV_BUCKET/ssl/$(echo $DOWNLOAD_SSL_CERTS | tr [A-Z] [a-z]).key /etc/nginx/certs/
  chmod 400 /etc/nginx/certs/$(echo $DOWNLOAD_SSL_CERTS | tr [A-Z] [a-z]).key
fi

# Warn if the DOCKER_HOST socket does not exist
if [[ $DOCKER_HOST == unix://* ]]; then
	socket_file=${DOCKER_HOST#unix://}
	if ! [ -S $socket_file ]; then
		cat >&2 <<-EOT
			ERROR: you need to share your Docker host socket with a volume at $socket_file
			Typically you should run your jwilder/nginx-proxy with: \`-v /var/run/docker.sock:$socket_file:ro\`
			See the documentation at http://git.io/vZaGJ
		EOT
		socketMissing=1
	fi
fi

# If the user has run the default command and the socket doesn't exist, fail
if [ "$socketMissing" = 1 -a "$1" = forego -a "$2" = start -a "$3" = '-r' ]; then
	exit 1
fi

exec "$@"
