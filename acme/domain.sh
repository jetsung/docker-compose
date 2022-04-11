#!/bin/sh

###
# https://github.com/acmesh-official/acme.sh/wiki/Run-acme.sh-in-docker
###

set -e

TYPE="${1}"

DOMAIN="${2}"

#COMMAND=acme.sh

COMMAND="docker  exec  acme.sh"

DNS_TYPE="dns_ali"

CA_TYPE=""

EMAIL="notify@example.com"

if test -z ${DOMAIN}; then 
        printf "\e[1;31mPlease input domain\e[0m\n"; exit 1;
fi

if ! test -z ${3}; then
        DNS_TYPE=$3
fi

if test "no" = "${DNS_TYPE}"; then
        DNS_TYPE="dns_ali"
fi

if ! test -z ${4}; then
        CA_TYPE=$4
fi
  
CA_STR=""
if test "letsencrypt" = "${CA_TYPE}"; then
        CA_STR="--server letsencrypt"
elif test "zerossl" = "${CA_TYPE}"; then
        CA_STR="--server zerossl"
elif test "google" = "${CA_TYPE}"; then
        CA_STR="--server google"
fi

if [ "${CA_STR}"x != "x" ]; then
        ${COMMAND} acme.sh --register-account -m $EMAIL $CA_STR
fi

if test "new" = ${TYPE}; then
  # 泛解析
        ${COMMAND} --issue --dns $DNS_TYPE -d ${DOMAIN} -d *.${DOMAIN} --keylength ec-256 --ecc --force $CA_STR
elif test "new2" = ${TYPE}; then
  # 非泛解析
        ${COMMAND} --issue --dns $DNS_TYPE -d ${DOMAIN} --keylength ec-256 --ecc --force $CA_STR
elif test "new3" = ${TYPE}; then
  # 非泛解析，170天，Wildcard not supported
        ${COMMAND} acme.sh --server https://api.buypass.com/acme/directory --register-account  --accountemail ${EMAIL}
        ${COMMAND} acme.sh --server https://api.buypass.com/acme/directory --issue --dns ${DNS_TYPE} -d ${DOMAIN} --keylength ec-256 --ecc --force --days 170
fi

${COMMAND} --install-cert --ecc -d ${DOMAIN} --key-file /data/ssl/${DOMAIN}.key --fullchain-file /data/ssl/${DOMAIN}.fullchain.cer

