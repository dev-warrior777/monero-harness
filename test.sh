#!/usr/bin/env bash

source monero_functions.inc

echo "---------------------------------"
echo "alpha info"
monero-rpc-request 48081 "get_info" "{}"
echo "---------------------------------"
echo "beta info"
monero-rpc-request 58081 "get_info" "{}"
echo "---------------------------------"

# echo "alpha connections"
# monero-rpc-request 88081 "get_connections" "{}"
# echo "---------------------------------"
# echo "beta connections"
# monero-rpc-request 98081 "get_connections" "{}"
# echo "---------------------------------"
