#!/usr/bin/env bash

# quick & dirty daemon killer
ps -e | grep monerod
killall -9 monerod
sleep 1