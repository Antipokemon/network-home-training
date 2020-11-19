FROM centos:7

    # Dependencies
RUN yum -y install libpng gcc-c++ bzip2 cronie vim && \
    # Install moloch - You can update this line to the latest build as needed
    yum -y install https://s3.amazonaws.com/files.molo.ch/builds/centos-7/moloch-2.7.0-1.x86_64.rpm && \
    ln -s /data/moloch/bin/node /usr/bin/node && \
    cd /data/moloch/viewer && \
    /data/moloch/bin/npm install fs-ext && \
    /data/moloch/bin/npm update && \
    /data/moloch/bin/npm rebuild && \
    # Remove gcc-c++ so nothing else can be built in the container
    yum -y autoremove gcc-c++ && \
    yum -y autoremove && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    # Pull maxmind Geo info for countries
    curl -L -o /tmp/GeoLite2-Country.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=GDqrbhx8P5vE&suffix=tar.gz" && \
    # Pull maxmind Geo info for ASNs
    curl -L -o /tmp/GeoLite2-ASN.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=GDqrbhx8P5vE&suffix=tar.gz" && \
    curl -L -o /data/moloch/etc/ipv4-address-space.csv "https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.csv" && \
    curl -L -o /data/moloch/etc/oui.txt "https://raw.githubusercontent.com/wireshark/wireshark/master/manuf" && \
    # Modify SMB parser to add additional fields from smb.lua
    echo '    +arrayList(session.smb, "opcode", "OpCode", "smb.opcode")' >> /data/moloch/parsers/smb.detail.jade && \
    echo '    +arrayList(session.smb, "cmd", "Command", "smb.cmd")' >> /data/moloch/parsers/smb.detail.jade && \
    # Create file to test if it has been started before
    echo "0" > /init.txt


# Copy lua script parsers
COPY lua/dcerpc.lua /data/moloch/lua/dcerpc.lua
COPY lua/smb.lua /data/moloch/lua/smb.lua
COPY lua/entropy.lua /data/moloch/lua/entropy.lua

# Copy wise dependencies
COPY wise/source.majestic.js /data/moloch/wiseService/source.majestic.js
COPY wise/wiseService.ini /data/moloch/etc/wiseService.ini

# Copy moloch's config file
COPY config/config.ini /data/moloch/etc/config.ini

# Copy start script to /data/startmoloch.sh
COPY entrypoint/startmoloch.sh /data/startmoloch.sh
RUN chmod +x /data/startmoloch.sh

RUN sed -i -e '7820i      session.fileId = [seq];' /data/moloch/viewer/viewer.js


WORKDIR /data/moloch/viewer
CMD /bin/bash

# Runs this script upon start of container
ENTRYPOINT ["/data/startmoloch.sh"]
