#!/bin/bash

cp /data/moloch/etc/config.ini /data/moloch/etc/config.ini.new
sed -i "s/interface=.*$/interface=$INTERFACE/g" /data/moloch/etc/config.ini.new
cp -f /data/moloch/etc/config.ini.new /data/moloch/etc/config.ini

# wait for Elasticsearch
echo "Giving Elasticsearch time to start..."
sleep 20

if (($INIT==TRUE))
then
  # Initialize Elasticsearch for Arkime data.
  echo "Initializing elasticsearch database."
  echo INIT | /data/moloch/db/db.pl http://localhost:9200 init
  /data/moloch/bin/moloch_add_user.sh admin "Admin User" password --admin
fi

# Start WISE service.
echo "Starting WISE tagger."
# This command seems to need to be run from the directory itself. During testing it wouldn't run properly unless you cd to the directory.
/bin/bash -c 'cd /data/moloch/wiseService; /data/moloch/bin/node wiseService.js &'
sleep 5

if (($CAPTURE==TRUE))
then
  # Start Capture service
  echo "Starting arkime-capture."
  /bin/bash -c "/data/moloch/bin/moloch-capture -c /data/moloch/etc/config.ini --host $HOSTNAME >> /data/moloch/logs/capture.log 2>&1 &"
fi

# Start Viewer service.
echo "Starting arkime-viewer."
cd /data/moloch/viewer
/bin/bash -c "/data/moloch/bin/node viewer.js -c /data/moloch/etc/config.ini >> /data/moloch/logs/viewer.log 2>&1"