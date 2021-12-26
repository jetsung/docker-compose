#!/bin/sh

###
# https://github.com/acmesh-official/acme.sh/wiki/Run-acme.sh-in-docker
###

set -e

TYPE=$1

DOMAIN=$2

#COMMAND=acme.sh

COMMAND="docker exec acme.sh"

DNS_TYPE="dns_ali"

if test -z $DOMAIN; then 
	printf "\e[1;31mPlease input domain\e[0m\n"; exit 1;
fi

if !(test -z ${3}); then
	DNS_TYPE=$3
fi

if test "new" = $TYPE; then
	${COMMAND} --issue --dns $DNS_TYPE -d ${DOMAIN} -d *.${DOMAIN} --keylength ec-256 --ecc --force --server letsencrypt 
fi

${COMMAND} --install-cert --ecc -d ${DOMAIN} --key-file   /data/ssl/${DOMAIN}.key --fullchain-file /data/ssl/${DOMAIN}.fullchain.cer

