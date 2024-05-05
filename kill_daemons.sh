#!/usr/bin/env bash
# bunuh djinn
# quick & dirty daemon killer
ps -e | grep monerod
killall -9 monerod
sleep 1