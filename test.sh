#!/usr/bin/env bash

source monero_functions.inc

monero-rpc-request 28081 "get_info" "{}"
monero-rpc-request 38081 "get_info" "{}"