FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y \
    --no-install-recommends \
    mpd xz-utils alsa-utils pipewire wget ffmpeg curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG S6_OVERLAY_VERSION=3.1.4.2
#ARG TARGETARCH=armv7l
ENV ARCH=armhf

WORKDIR /

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-${ARCH}.tar.xz

WORKDIR /

RUN mkdir -p /var/lib/mpd/config

RUN touch /var/lib/mpd/config/pid /var/lib/mpd/config/state /var/lib/mpd/config/sticker.sql

RUN chmod 777 /var/lib/mpd/config/pid /var/lib/mpd/config/state /var/lib/mpd/config/sticker.sql

EXPOSE 6600

#CMD ["/usr/bin/mpd", "--no-daemon"]
CMD ["mpd", "--stdout", "--no-daemon"]
