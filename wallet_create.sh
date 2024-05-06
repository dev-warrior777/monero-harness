#!/usr/bin/env bash
# Script for creating xmr wallets. xmr harness should be running before executing.

source monero_functions.inc

# positional
name=$1
seed=$2
pass=$3

if [ "${name}" == "" ]; then
    name="wallet.bin"
fi

wallet_dir=./test_wallets/regtest
if [ ! -d ${wallet_dir} ]; then
    mkdir -p ${wallet_dir}
fi

if [ -f "${wallet_dir}/${name}" ]; then
    echo "${name} already exists"
    exit 1
fi

create_mode="create"
if [ "${seed}" != "" ]; then
    create_mode="recreate"
fi

# default to the fred wallet rpc port
port=28884

params='{"filename":"'"${name}"'","password":"${pass}","language":"English"}'
echo "${params}"

monero-rpc-request "${port}" "create-wallet" "${params}"
