# Dockerfile for suricata

FROM ubuntu:20.04

ENV TZ=Etc/UTC
ARG DEBIAN_FRONTEND=noninteractive
    # Dependencies
RUN apt update && apt install -y libpcre3 libpcre3-dbg libpcre3-dev build-essential \
    libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev pkg-config zlib1g zlib1g-dev liblz4-dev \
    libcap-ng-dev libcap-ng0 make libmagic-dev curl libjansson-dev libluajit-5.1-dev \
    libnss3-dev libgeoip-dev liblua5.1-dev libhiredis-dev libevent-dev libmaxminddb-dev \
    python-yaml rustc cargo && cargo install --force --debug --version 0.14.1 cbindgen && \
    # Pull and install suricata
    curl -o /opt/suricata.tar.gz https://www.openinfosecfoundation.org/download/suricata-6.0.0.tar.gz &&\
    tar -zxf /opt/suricata.tar.gz && rm -f /opt/suricata.tar.gz && \
    mv suricata* /opt/suricata && cd /opt/suricata && \
    # configure suricata
    ./configure --prefix=/usr --sysconfdir=/etc \
    --localstatedir=/var --enable-nfqueue --enable-geopip \
    --enable-rust --enable-python --enable-libmagic --enable-luajit \
    --enable-geoip --enable-hiredis && make && make install && ldconfig && \
    make install-full && \
    # cleanup
    rm -f /opt/suricata.tar.gz &&\
    find /var/log -type f -delete && rm -rf /opt/suricata 

RUN apt -y install logrotate && mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate

COPY suricata /etc/logrotate.d/suricata

RUN suricata-update update-sources && suricata-update enable-source et/open && suricata-update enable-source oisf/trafficid && suricata-update enable-source sslbl/ja3-fingerprints && suricata-update enable-source ptresearch/attackdetection && suricata-update enable-source sslbl/ssl-fp-blacklist && suricata-update enable-source tgreen/hunting && suricata-update enable-source etnetera/aggressive

RUN mknod /var/log/suricata/eve.json p && mknod /var/log/suricata/moloch.json p && mknod /var/log/suricata/filebeat.json p

CMD suricata --af-packet
