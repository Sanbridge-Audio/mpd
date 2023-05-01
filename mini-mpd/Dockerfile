FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y mpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 6600

CMD ["/usr/bin/mpd", "--no-daemon"]
