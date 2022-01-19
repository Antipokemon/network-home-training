# **Update 19 Jan 2022**
1. Updated file paths for newer Arkime structure.
2. Updated suricata to newest version and added version variable in .env
3. Suricata Dockerfile - Added required dependecy for building suricata.
4. Arkime Dockerfile - Added more RUN fields to cache for easier error checking.

# **Instructions**
**Note:** As the MIP is built using Fedora, these instructions use commands for Fedora. For Ubuntu/Debian, adjust commands as necessary.

## Install Docker
https://docs.docker.com/engine/install/fedora/
1. **sudo dnf -y install dnf-plugins-core**
2. **sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo**
3. **sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose**
4. Start and enable docker service: **sudo systemctl start docker && sudo systemctl enable docker**
5. Add your user to docker group: **sudo usermod -aG docker $USER**
6. Login to the new group: **newgrp docker**

## Clone git repository
**Note**: The intent for this is to be run on your MIP. These commands should be run as the normal assessor user. If you are running it on your home computer, you may need to adjust the commands for the OS you are running.
1. Go to directory you want to store your docker data in:
    1. If git is needed: **sudo dnf install git -y**
    2. **git clone https://bitbucket.di2e.net/scm/cyh836/network-home-training.git**
2. **cd network-home-training**

## Run
1. You will need to modify the INTERFACE variable in the .env file of the root folder. (Same folder as the docker-compose.yml)
    1. Find the interface of your computer and replace eno1 of INTERFACE=eno1 with your interface name. Ex: INTERFACE=enp6s0.
2. Chmod the directory moloch writes pcap to: **chmod 777 moloch/raw**
3. Chmod the directory elastic writes node data to: **chmod 777 elastic/moloch-data/nodes**
4. **docker-compose up -d**

## **View Running Services**
1. **Arkime** - localhost:8005
    1. User: admin
    2. Password: password
2. **Kibana** - localhost:5601  
    1. You will likely need to create index patterns on first run.
        1. Hamburger Icon > Stack Management > Index Patterns > Create index pattern.
        2. In the index pattern name field you will need to create 2 index names.
            1. 'sessions2-'
            2. 'filebeat-'
        3. Kibana will append a * to the end. Leave it there.
        4. When asked for Time field, select @timestamp for both.
3. **Elastic** - localhost:9200

# **Running pcap through Arkime (Moloch)**
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

**Note**: The " >> /data/moloch/logs/capture.log 2>&1 &" portion of the command is to run the command in the background and sends all log messages to capture.log

# Modifying Things
## Arkime
**Notes:**
1. Arkime will collect traffic from your interface unless you change the value in the .env file. It looks for 'TRUE' without the quotes. If it's not there it will not capture off the wire, but the files must exist or it will error.
2. Arkime has been set to reinitialize the database on each run. To change this, modify the .env file and change TRUE for CAPTURE=TRUE to another value. Ex: CAPTURE=FALSE, CAPTURE=OFF.
    1. Any value here will work as it is only looks for a TRUE value to reinitialize the database.

**WISE Tags** - https://arkime.com/wise

To add more custom WISE tags add the file to moloch/tags then add it to moloch/wise/wiseService.ini


Create a [file:UNIQUENAME] section to configure
|Setting   |	Default  |	Description|
|----------|-------------|--------------|
|file      |   REQUIRED  |	The file to load
|tags      |   REQUIRED  |	Comma separated list of tags to set for matches
|type      |   REQUIRED  |	The type of data in the file, such as ip,domain,md5,ja3,email, or something defined in [wise-types]
|format    |   csv       |	csv,Tagger Format,json - The format of data file
|keyColumn |   0         |	For json formatted files, which json field is the key
|column    |   0         |	For csv formatted files, which column is the data

When adding it to the wiseService.ini, remember that you need to specify the directory inside the container. This is setup to be /data/moloch/tags as shown in the below example.

```
[file:autotag_ip]
file=/data/moloch/tags/autotag_ip.tagger
type=ip
format=tagger
```
There are also other Third Party sources available to use with WISE, but need a key. Read the docs at the above link to figure out how.

**Lua Parsers** - https://confluence.di2e.net/display/CYH836/Moloch+-+LUA+Scripting

As this is covered elsewhere, the only added info is to place the lua files in the moloch/lua directory
## Suricata
Add more rules - https://suricata.readthedocs.io/en/suricata-6.0.0/configuration/suricata-yaml.html#rules

Go down to line 1804 in suricata/etc/suricata.yaml/suricata.yaml and add the files to the list of current rules files.
```
default-rule-path: /etc/suricata/rules
rule-files:
 - misp_admin.rules
 - domain.rules
 - Added_rules_file.rules
```

**Edit the config** - https://suricata.readthedocs.io/en/suricata-6.0.0/configuration/suricata-yaml.html#

As there are many options, this will not be covered. Just know that options like enabling JA3s, parsing smtp, smb, nfs, krb5, etc are all options that can be turned off or on.

The suricata.yaml is a large file and, if intersted in learning the capabilities suricata has, reading the documentation provided by suricata is the best option.

Lastly, Mr. Dietrich created a suricata training. It may help to seek that out.

# **Resources**
**Note**: This section is for reference material for those who may want to learn more about the tools used in this repo. Those interested in being kit SMEs should get more familiar with this documentation.

1. docker documentation - https://docs.docker.com/reference/
2. docker-compose documentation- https://docs.docker.com/compose/
3. Arkime(Moloch) FAQ - https://arkime.com/faq
4. Arkime Github - https://github.com/arkime/arkime
5. WISE tagger - https://arkime.com/wise
6. Kibana documentation - https://www.elastic.co/guide/en/kibana/current/index.html
7. Elasticsearch documentation - https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html
    1. Node description - https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html
    2. Shard description - https://www.elastic.co/guide/en/elasticsearch/guide/2.x/_add_an_index.html
    3. Index description - https://www.elastic.co/blog/what-is-an-elasticsearch-index
8. Suricata documentation - https://suricata.readthedocs.io/en/suricata-6.0.0/

# **Update 27 Mar 2021**
1. Zeek and Filebeat have been added. Zeek will run against live traffic and logs will show in kibana.
2. Added .env file to simplify interface to use.
3. Cleaned up README.md to be more clear and less of a mess.