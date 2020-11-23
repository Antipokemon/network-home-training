# Instructions
**Note**: The intent for this is to be run on your MIP. These commands should be run as the normal assessor user. If you are running it on your home computer, you may need to adjust the commands for the OS you are running.
1. Go to directory you want to store your docker data in:
    1. If needed, **sudo dnf install git -y**
    2. **git clone https://bitbucket.di2e.net/scm/cyh836/network-home-training.git**
2. **cd network-home-training**
3. If needed, **sudo dnf install docker-ce docker-compose -y**
4. Add your user to docker group **sudo usermod -aG docker $USER**
5. **docker-compose up -d**

# Running pcap through Arkime (Moloch)
**Note**: It is recommended by the Arkime developers to only run .pcap files through Arkime. Other file types may work, but are not supported.
## Outside the container
**Note**: If in doubt, add the "--dryrun" flag to your moloch-capture command to test the run.
1. To run capture on **ALL** pcap within the pcap folder:
    1. **docker exec "data/moloch/bin/moloch-capture -c /data/moloch/etc/config.ini -R /data/pcap --host $HOSTNAME >> /data/moloch/logs/capture.log 2>&1 &"**
2. To run capture on an individual pcap file in the pcap folder:
    1. **docker exec "data/moloch/bin/moloch-capture -c /data/moloch/etc/config.ini -r /data/pcap/<name of file.pcap> --host $HOSTNAME >> /data/moloch/logs/capture.log 2>&1 &"**
3. If you are unsure whether a pcap file has already been parsed add the -s option to skip already processed files.
    1. **Example**: docker exec "data/moloch/bin/moloch-capture -c /data/moloch/etc/config.ini -s -R /data/pcap --host $HOSTNAME >> /data/moloch/logs/capture.log 2>&1 &"

**Note**: The " >> /data/moloch/logs/capture.log 2>&1 &" portion of the command is to run the command in the background and send all log messages to capture.log

## Inside the container
**Note**: If in doubt, add the "--dryrun" flag to your moloch-capture command to test the run.
1. **docker exec -it moloch /bin/bash**
2. To run capture on **ALL** pcap within the pcap folder:
    1. **data/moloch/bin/moloch-capture -c /data/moloch/etc/config.ini -R /data/pcap --host $HOSTNAME >> /data/moloch/logs/capture.log 2>&1 &**
3. To run capture on an individual pcap file in the pcap folder:
    1. **data/moloch/bin/moloch-capture -c /data/moloch/etc/config.ini -r /data/pcap/<name of file.pcap> --host $HOSTNAME >> /data/moloch/logs/capture.log 2>&1 &**
4. If you are unsure whether a pcap file has already been parsed add the -s option to skip already processed files.
    1. **Example**: docker exec "data/moloch/bin/moloch-capture -c /data/moloch/etc/config.ini -s -R /data/pcap --host $HOSTNAME >> /data/moloch/logs/capture.log 2>&1 &"

**Note**: The " >> /data/moloch/logs/capture.log 2>&1 &" portion of the command is to run the command in the background and send all log messages to capture.log


# ****Still working on a way to parse pcap through Arkime and Suricata simultaneously**
```
moloch-capture -h
Usage:
  moloch-capture [OPTION?] - capture

Help Options:
  -h, --help         Show help options

Application Options:
  -c, --config       Config file name, default '/data/moloch/etc/config.ini'
  -r, --pcapfile     Offline pcap file
  -R, --pcapdir      Offline pcap directory, all *.pcap files will be processed
  -m, --monitor      Used with -R option monitors the directory for closed files
  --packetcnt        Number of packets to read from each offline file
  --delete           In offline mode delete files once processed, requires --copy
  -s, --skip         Used with -R option and without --copy, skip files already processed
  --reprocess        In offline mode reprocess files, use the same files table entry
  --recursive        When in offline pcap directory mode, recurse sub directories
  -n, --node         Our node name, defaults to hostname.  Multiple nodes can run on same host
  --host             Override hostname, this is what remote viewers will use to connect
  -t, --tag          Extra tag to add to all packets, can be used multiple times
  -F, --filelist     File that has a list of pcap file names, 1 per line
  --op               FieldExpr=Value to set on all session, can be used multiple times
  -o, --option       Key=Value to override config.ini
  -v, --version      Show version number
  -d, --debug        Turn on all debugging
  -q, --quiet        Turn off regular logging
  --copy             When in offline mode copy the pcap files into the pcapDir from the config file
  --dryrun           dry run, nothing written to databases or filesystem
  --flush            In offline mode flush streams between files
  --insecure         insecure https calls
  --nolockpcap       Don't lock offline pcap files (ie., allow deletion)
```

# Resources
**Note**: This section is for reference material for those who may want to learn more about the tools used in this repo. Those interested in being kit SMEs should get more familiar with this documentation.

docker documentation - https://docs.docker.com/reference/  
docker-compose documentation- https://docs.docker.com/compose/  
Arkime(Moloch) FAQ - https://arkime.com/faq  
Arkime Github - https://github.com/arkime/arkime  
Kibana documentation - https://www.elastic.co/guide/en/kibana/current/index.html  
Elasticsearch documentation - https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html  
Suricata documentation - https://suricata.readthedocs.io/en/suricata-6.0.0/


# Future:
podman  
podman-compose
