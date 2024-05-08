#!/usr/bin/env bash
# bunuh djinn
# quick & dirty daemon killer
ps -e | grep monero
killall -9 monero-wallet-rpc
killall -9 monerod
sleep 1