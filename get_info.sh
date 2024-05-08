#!/usr/bin/env bash

source monero_functions.inc

echo "---------------------------------"
echo "alpha info"
monero-rpc-request 18081 "get_info" "{}"
echo "---------------------------------"
