FROM ubuntu:focal

LABEL MAINTAINER="xjasonlyu"
# https://askubuntu.com/questions/972516/debian-frontend-environment-variable
ARG DEBIAN_FRONTEND="noninteractive"
# http://stackoverflow.com/questions/48162574/ddg#49462622
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
# https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support)
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y ca-certificates gnupg curl apt-transport-https \
    && curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - \
    && echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release ) $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) main" | tee /etc/apt/sources.list.d/jellyfin.list \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
        jellyfin \
        libva2 \
        i965-va-driver \
        mesa-va-drivers \
        intel-media-va-driver-non-free \
        openssl \
        libfreetype6 \
        libfontconfig1 \
        fonts-wqy-zenhei \
    && apt-get remove gnupg curl apt-transport-https -y \
    && apt-get clean autoclean -y \
    && apt-get autoremove -y \
    && mkdir -p \
        /config/{log,data/transcodes,cache} \
        /media \
    && chmod -R 777 /config /media \
    && rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

ENV JELLYFIN_CONFIG_DIR=/config
ENV JELLYFIN_DATA_DIR=/config/data
ENV JELLYFIN_LOG_DIR=/config/log
ENV JELLYFIN_CACHE_DIR=/config/cache

EXPOSE 8096
VOLUME /config /media

ENTRYPOINT ["./jellyfin/jellyfin", \
    "--datadir", "/config", \
    "--cachedir", "/cache", \
    "--ffmpeg", "/usr/lib/jellyfin-ffmpeg/ffmpeg"]
    
    

