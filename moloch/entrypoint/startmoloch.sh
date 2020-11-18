#!/bin/bash

value=$(cat /init.txt)

# wait for Elasticsearch
echo "Giving ES time to start..."
sleep 10

if (($value!=1)); then
  # intialize moloch
  echo INIT | /data/moloch/db/db.pl http://elasticsearch:9200 init
  /data/moloch/bin/moloch_add_user.sh admin "Admin User" password --admin
  echo "1" > /init.txt
fi

# Start moloch-capture
echo "Starting moloch-capture on default interface."
/bin/bash -c "/data/moloch/bin/moloch-capture -c /data/moloch/etc/config.ini --host $HOSTNAME >> /data/moloch/logs/capture.log 2>&1 &"

# Start moloch-viewer
echo "Starting moloch-viewer"
/bin/bash -c "/data/moloch/bin/node /data/moloch/viewer/viewer.js -c /data/moloch/etc/config.ini >> /data/moloch/logs/viewer.log 2>&1"
