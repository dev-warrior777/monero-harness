#!/usr/bin/env bash

source monero_functions.inc

echo "---------------------------------"
echo "alpha connections"
monero-rpc-request 48081 "get_connections" "{}"
echo "---------------------------------"
echo "beta connections"
monero-rpc-request 58081 "get_connections" "{}"
echo "---------------------------------"
