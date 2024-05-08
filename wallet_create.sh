#!/usr/bin/env bash
# Script for creating xmr wallets. xmr harness should be running before executing.

source monero_functions.inc

create_wallet $1 $2 $3
