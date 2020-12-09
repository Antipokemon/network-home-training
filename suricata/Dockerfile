# Dockerfile for suricata

FROM centos:7

    # Dependencies
RUN yum -y install epel-release && yum -y install cronie initscripts gcc gcc-c++ libpcap libpcap-devel pcre-devel \
    libyaml-devel file-devel hiredis-devel libevent-devel geoip-devel libmaxminddb-devel libmaxminddb xz-devel luajit-devel lz4-devel \
    zlib-devel jansson jansson-devel nss-devel libcap-ng-devel libnet libnet-devel tar make \
    libnetfilter_queue libnetfilter_queue-devel lua-devel cargo openssl-devel python-yaml && cargo install cargo-vendor &&\
    # Pull and install suricata
    curl -o /opt/suricata.tar.gz https://www.openinfosecfoundation.org/download/suricata-6.0.0.tar.gz &&\
    tar -zxf /opt/suricata.tar.gz && rm -f /opt/suricata.tar.gz && \
    mv suricata* /opt/suricata && cd /opt/suricata && \
    # configure suricata
    ./configure --prefix=/usr --sysconfdir=/etc \
    --localstatedir=/var --enable-nfqueue --enable-geopip \
    --enable-rust --enable-python --enable-libmagic --enable-luajit \
    --enable-geoip --enable-hiredis && make && make install && ldconfig && \
    make install-full && yum -y remove gcc libpcap-devel pcre-devel libyaml-devel file-devel libmaxminddb-devel \
    zlib-devel jansson-devel nss-devel libcap-ng-devel libnet-devel make \
    libnetfilter_queue-devel lua-devel cargo && \
    # cleanup
    rm -f /opt/suricata.tar.gz && yum clean all &&\
    rm -rf /var/cahce/yum && find /var/log -type f -delete && rm -rf /opt/suricata 

RUN yum -y install logrotate && mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate

COPY suricata /etc/logrotate.d/suricata

RUN suricata-update update-sources && suricata-update enable-source et/open && suricata-update enable-source oisf/trafficid && suricata-update enable-source sslbl/ja3-fingerprints && suricata-update enable-source ptresearch/attackdetection && suricata-update enable-source sslbl/ssl-fp-blacklist && suricata-update enable-source tgreen/hunting && suricata-update enable-source etnetera/aggressive

RUN mknod /var/log/suricata/eve.json p && mknod /var/log/suricata/moloch.json p && mknod /var/log/suricata/filebeat.json p

CMD suricata --af-packet
