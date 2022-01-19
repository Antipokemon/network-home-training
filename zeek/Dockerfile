# Zeek latest lts from ubuntu repo

FROM ubuntu:20.04

ENV TZ=Etc/UTC
ARG DEBIAN_FRONTEND=noninteractive

    # add basic utilities
RUN apt update && apt install gpg curl vim -y && \
    # add repo with zeek
    echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_20.04/ /' | tee /etc/apt/sources.list.d/security:zeek.list && \
    curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_20.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null && \
    apt update && \
    # install zeek
    apt install zeek-lts -y

RUN mkdir /zeek
WORKDIR /zeek