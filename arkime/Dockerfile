FROM ubuntu:20.04

RUN apt update -y && \
    apt install -y gcc vim python3 python3-pip curl jq && pip3 install yq

RUN export VERSION=$(curl https://s3.amazonaws.com/files.molo.ch/ | xq . | grep Key | awk -F '"' '{print $4}' | \
    grep builds/ubuntu-20.04 | tail -1 | awk -F '/' '{print $3}') && \
    curl -O https://s3.amazonaws.com/files.molo.ch/builds/ubuntu-20.04/$VERSION && \
    apt install -y ./$VERSION && \
    rm -f $VERSION

    # Pull maxmind Geo info for countries
RUN curl -L -o /tmp/GeoLite2-Country.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=GDqrbhx8P5vE&suffix=tar.gz" && \
    # Pull maxmind Geo info for ASNs
    curl -L -o /tmp/GeoLite2-ASN.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=GDqrbhx8P5vE&suffix=tar.gz" && \
    curl -L -o /data/moloch/etc/ipv4-address-space.csv "https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.csv" && \
    curl -L -o /data/moloch/etc/oui.txt "https://raw.githubusercontent.com/wireshark/wireshark/master/manuf" && \
    # Modify SMB parser to add additional fields from smb.lua
    echo '    +arrayList(session.smb, "opcode", "OpCode", "smb.opcode")' >> /data/moloch/parsers/smb.detail.jade && \
    echo '    +arrayList(session.smb, "cmd", "Command", "smb.cmd")' >> /data/moloch/parsers/smb.detail.jade && \
    # Create file to test if it has been started before
    echo "0" > /init.txt && \
    # Create tags folder
    mkdir /data/moloch/tags/

RUN tar -ztf /tmp/GeoLite2-Country.tar.gz | grep mmdb | xargs -I X tar -Ozxf /tmp/GeoLite2-Country.tar.gz X >> /data/moloch/etc/GeoLite2-Country.mmdb && \
    tar -ztf /tmp/GeoLite2-ASN.tar.gz | grep mmdb | xargs -I X tar -Ozxf /tmp/GeoLite2-ASN.tar.gz X >> /data/moloch/etc/GeoLite2-ASN.mmdb && \
    rm -rf /tmp/GeoLite2-*

# Copy lua script parsers
COPY lua/dcerpc.lua /data/moloch/lua/dcerpc.lua
COPY lua/smb.lua /data/moloch/lua/smb.lua
COPY lua/entropy.lua /data/moloch/lua/entropy.lua

# Copy wise dependencies
# COPY wise/source.majestic.js /data/moloch/wiseService/source.majestic.js
COPY wise/wiseService.ini /data/moloch/etc/wiseService.ini

# Copy arkime's config file
COPY config/config.ini /data/moloch/etc/config.ini

# Copy start script to /data/startarkime.sh
COPY entrypoint/startarkime.sh /data/startarkime.sh
RUN chmod +x /data/startarkime.sh

WORKDIR /data/moloch/viewer
CMD /bin/bash

# Runs this script upon start of container
ENTRYPOINT ["/data/startarkime.sh"]
