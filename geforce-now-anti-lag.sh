#!/bin/bash

echo "Running awdl0 disabler.... "
# 
open -a /Applications/GeForceNOW.app
# Disable awdl0 to reduce latency for GeForce NOW
while true; do
    awdl0_state=$(sudo /sbin/ifconfig awdl0 | grep status | awk '{ print $2}')
    if [ "$awdl0_state" == "active" ]; then
        printf "."
        sudo /sbin/ifconfig awdl0 down
    else
        sleep 2
    fi
done
