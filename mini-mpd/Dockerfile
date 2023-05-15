FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y mpd xz-utils pulse audio pulseaudio-utils
 && \
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

EXPOSE 6600

#CMD ["/usr/bin/mpd", "--no-daemon"]
CMD ["mpd", "--stdout", "--no-daemon"]