#!/bin/bash

init=$(cat /init.txt)
capture=$(cat /capture.txt)

# wait for Elasticsearch
echo "Giving ES time to start..."
sleep 20

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
  /bin/bash -c "/data/moloch/bin/moloch-capture --debug -c /data/moloch/etc/config.ini --host $HOSTNAME >> /data/moloch/logs/capture.log 2>&1 &"
fi

# Start WISE
echo "Starting WISE"
# This command seems to need to be run from the directory itself. During testing it wouldn't run properly unless you cd to the directory.
/bin/bash -c 'cd /data/moloch/wiseService; /data/moloch/bin/node wiseService.js &'

# Start Viewer
echo "Starting moloch-viewer"
cd /data/moloch/viewer
/bin/bash -c "/data/moloch/bin/node viewer.js -c /data/moloch/etc/config.ini >> /data/moloch/logs/viewer.log 2>&1"