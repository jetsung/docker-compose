#!/bin/sh

###
# https://github.com/acmesh-official/acme.sh/wiki/Run-acme.sh-in-docker
###

set -e

TYPE=$1

DOMAIN=$2

#COMMAND=acme.sh

COMMAND="docker  exec  acme.sh"

DNS_TYPE="dns_ali"

if test -z $DOMAIN; then 
	printf "\e[1;31mPlease input domain\e[0m\n"; exit 1;
fi

if !(test -z ${3}); then
	DNS_TYPE=$3
fi

#${COMMAND} acme.sh --register-account -m yourname@yourdomain.com
#${COMMAND} acme.sh --server https://api.buypass.com/acme/directory --register-account  --accountemail yourname@yourdomain.com

if test "new" = $TYPE; then
  # 泛解析
	${COMMAND} --issue --dns $DNS_TYPE -d ${DOMAIN} -d *.${DOMAIN} --keylength ec-256 --ecc --force 
elif test "new2" = $TYPE; then
  # 非泛解析
	${COMMAND} --issue --dns $DNS_TYPE -d ${DOMAIN} --keylength ec-256 --ecc --force 
elif test "new3" = $TYPE; then
  # 非泛解析，170天，Wildcard not supported
	${COMMAND} acme.sh --server https://api.buypass.com/acme/directory --issue --dns $DNS_TYPE -d ${DOMAIN} --keylength ec-256 --ecc --force --days 170
fi

${COMMAND} --install-cert --ecc -d ${DOMAIN} --key-file /data/ssl/${DOMAIN}.key --fullchain-file /data/ssl/${DOMAIN}.fullchain.cer
