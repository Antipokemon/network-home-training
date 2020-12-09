#!/bin/bash

init=$(cat /init.txt)
capture=$(cat /capture.txt)

# wait for Elasticsearch
echo "Giving ES time to start..."
sleep 15

if (($init==0))
then
  # intialize moloch
  echo INIT | /data/moloch/db/db.pl http://localhost:9200 init
  /data/moloch/bin/moloch_add_user.sh admin "Admin User" password --admin
  echo "1" > /init.txt
fi

if (($capture==TRUE))
then
  #Start Capture
  echo "Starting moloch-capture on default interface."
  /bin/bash -c "/data/moloch/bin/moloch-capture -c /data/moloch/etc/config.ini --host $HOSTNAME >> /data/moloch/logs/capture.log 2>&1 &"
fi

# Start Viewer
echo "Starting moloch-viewer"
cd /data/moloch/viewer
/bin/bash -c "/data/moloch/bin/node viewer.js -h"
/bin/bash -c "/data/moloch/bin/node viewer.js -c /data/moloch/etc/config.ini >> /data/moloch/logs/viewer.log 2>&1"