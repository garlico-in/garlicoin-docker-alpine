#!/bin/bash

mkdir -p /root/garlicoin_data/garlicoind

# Start the Garlicoin process
/usr/local/bin/garlicoind -conf=/root/garlicoin.conf -datadir=/root/garlicoin_data/garlicoind
sleep 1

# Watch Process
while sleep 60; do
  ps aux | grep garlicoind | grep -q -v grep
  status=$?
  if [ $status -ne 0 ]; then
    echo "Garlicoind process has exited."
    exit 1
  fi
done