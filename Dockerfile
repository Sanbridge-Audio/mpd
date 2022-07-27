#Start dockerfile by creating all the dependencies needed.
FROM debian:stable AS depend
LABEL maintainer="Matt Dickinson <matt@sanbridge.org>" 

 
#Installation of all of the dependencies needed to build Music Player Daemon from source.
RUN apt-get update && apt-get install -y \
	curl \
	meson \
#	python3-sphinx \
	g++ \
	libfmt-dev \
	libpcre2-dev \
	libmad0-dev libmpg123-dev libid3tag0-dev \
	libflac-dev libvorbis-dev libopus-dev libogg-dev \
	libadplug-dev libaudiofile-dev libsndfile1-dev libfaad-dev \
	libfluidsynth-dev libgme-dev libmikmod-dev libmodplug-dev \
	libmpcdec-dev libwavpack-dev libwildmidi-dev \
	libsidplay2-dev libsidutils-dev libresid-builder-dev \
	libavcodec-dev libavformat-dev \
	libmp3lame-dev libtwolame-dev libshine-dev \
	libsamplerate0-dev libsoxr-dev \
	libbz2-dev libcdio-paranoia-dev libiso9660-dev libmms-dev \
	libzzip-dev \
	libcurl4-gnutls-dev libyajl-dev libexpat-dev \
	libasound2-dev libao-dev libjack-jackd2-dev libopenal-dev \
	libpulse-dev libshout3-dev \
	libsndio-dev \
	libmpdclient-dev \
	libnfs-dev \
	libupnp-dev \
	libavahi-client-dev \
	libsqlite3-dev \
	libsystemd-dev \
	libgtest-dev \
	libboost-dev \
	libicu-dev \
	libchromaprint-dev \
	libgcrypt20-dev \
	ninja-build \
	libboost-dev \
	wget \
	nano \
#Clean up the installation files. 
	&& apt-get clean && rm -fR /var/lib/apt/lists/*

#Setting a new stage for the dockerfile so that the cache can be utilized and the build can be sped up.
FROM depend AS mpdbuild

#Set default environmental variables. 
#Set the working directory of the dockerfile at this stage.
ENV HOME /root

 
#ARG MPD_VERSION=5 

#Set the mpd version. Makes it easier to update in the future.
ARG MPD_MAJOR_VERSION=0.23 
ARG MPD_MINOR_VERSION=8

#Set the s6 overlay version. Makes running mpd much easier. 


#Download the most recent MPD source file.
#https://www.musicpd.org/download/mpd/0.23/mpd-0.23.5.tar.xz
ADD https://www.musicpd.org/download/mpd/${MPD_MAJOR_VERSION}/mpd-${MPD_MAJOR_VERSION}.${MPD_MINOR_VERSION}.tar.xz /tmp
RUN tar xf /tmp/mpd-${MPD_MAJOR_VERSION}.${MPD_MINOR_VERSION}.tar.xz -C /

#ADD https://www.musicpd.org/download/mpc/0/mpc-${MPC_VERSION}.tar.xz /tmp
#RUN tar xf /tmp/mpc-${MPC_VERSION}.tar.xz

#ADD https://www.musicpd.org/download/mpd/0.23/mpd-0.23.${MPD_VERSION}.tar.xz /tmp
#RUN tar xf /tmp/mpd-0.23.${MPD_VERSION}.tar.xz -C /



#Change the working directory to MPD for installation.
WORKDIR mpd-${MPD_MAJOR_VERSION}.${MPD_MINOR_VERSION}

#Installation of MPD
RUN meson . output/release --buildtype=debugoptimized -Db_ndebug=true 
RUN ninja -C output/release
RUN ninja -C output/release install
ENV Version=${MPD_MAJOR_VERSION}.${MPD_MINOR_VERSION}

ARG MPC_VERSION=0.34
ADD https://www.musicpd.org/download/mpc/0/mpc-0.34.tar.xz /tmp
#ADD https://www.musicpd.org/download/mpc/0/mpc-${MPC_VERSION}.tar.xz /tmp
RUN tar xf /tmp/mpc-0.34.tar.xz

WORKDIR mpc-0.34

#Installation of MPC
RUN meson . output
RUN ninja -C output
RUN ninja -C output install


#Changing stage for the dockerfile to the configuration of MPD.
#FROM alpine AS config
FROM debian:stable-slim AS config
ARG S6_VERSION=2.2.0.3
ARG MPC_VERSION=0.34

#Change the working directory to root.
#WORKDIR $HOME

COPY --from=mpdbuild /usr/local/bin/mpc /usr/local/bin
COPY --from=mpdbuild /usr/local/bin/mpd /usr/local/bin

#RUN apk update && apk add \
RUN apt-get update && apt-get install -y \
	libmpdclient-dev \
	libdbus-1-3 \
	libfmt-dev \
#	libfmt-dev \
	libpcre2-dev \
 	libmad0-dev libmpg123-dev libid3tag0-dev \
	libflac-dev libvorbis-dev libopus-dev libogg-dev \
	libadplug-dev libaudiofile-dev libsndfile1-dev libfaad-dev \
  	libfluidsynth-dev libgme-dev libmikmod-dev libmodplug-dev \
 	libmpcdec-dev libwavpack-dev libwildmidi-dev \
  	libsidplay2-dev libsidutils-dev libresid-builder-dev \
  	libavcodec-dev libavformat-dev \
  	libmp3lame-dev libtwolame-dev libshine-dev \
  	libsamplerate0-dev libsoxr-dev \
  	libbz2-dev libcdio-paranoia-dev libiso9660-dev libmms-dev \
  	libzzip-dev \
  	libcurl4-gnutls-dev libyajl-dev libexpat-dev \
  	libasound2-dev libao-dev libjack-jackd2-dev libopenal-dev \
  	libpulse-dev libshout3-dev \
  	libsndio-dev \
  	libmpdclient-dev \
  	libnfs-dev \
  	libupnp-dev \
  	libavahi-client-dev \
  	libsqlite3-dev \
  	libsystemd-dev \
  	libgtest-dev \
  	libboost-dev \
  	libicu-dev \
  	libchromaprint-dev \
  	libgcrypt20-dev \
	mosquitto-clients \
	&& apt-get clean && rm -fR /var/lib/apt/lists/*
#	&& rm -fR /var/lib/apt/lists/*
#Download the most recent s6 overlay.
ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-amd64.tar.gz /tmp
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /



#Stopping the mpd service. Not certain if it's entirely necessary.
#RUN mpd stop
#RUN update-rc.d mpd disable 

#Make needed directories. Should match the config file.
RUN  mkdir -p /var/lib/mpd/music \
	&& mkdir -p ~/.mpd/playlists \
	&& mkdir -p ~/.config/mpd \
	&& chmod a+w ~/.mpd/playlists

#Create music, playlist, tmp (for sending audio to snapcast) and config folder.
VOLUME /var/lib/mpd/music /.mpd/playlists /tmp #/.config/mpd 
#/usr/local/bin/mpd

#Creating databases.
RUN touch /.mpd/mpd.log \
	&& touch /.mpd/sticker.sql \
	&& touch /.mpd/pid \
	&& touch /.mpd/mpdstate \
	&& touch /.mpd/tag_cache

#Add permissions to created databases
RUN chmod 777 /.mpd/mpd.log \
	&& chmod 777 /.mpd/sticker.sql \
	&& chown 777 /.mpd/pid \
	&& chmod 777 /.mpd/mpdstate \
	&& chmod 777 /.mpd/tag_cache

#Copy preset configuration file into image from folder. 
COPY mpd.conf /usr/local/etc

#Add permissions so that the configuration file will actually work
RUN chmod 777 /usr/local/etc/mpd.conf
#RUN chmod +rwx /usr/local/etc/mpd.conf
#Copy a services file that will allow MPD to find the mpd.conf file. 
COPY mpd.service /usr/local/lib/systemd/system Stations.m3u /.mpd/playlists

#Copy stations playlist into mpd playlists folder that was created earlier.
#COPY Stations.m3u /.mpd/playlists 

FROM config as mpd
ENV TZ="America/New_York"
#Consistent command across multiple types of mpd dockerfiles.
CMD ["mpd", "--stdout", "--no-daemon"]

ENTRYPOINT ["/init"]

#Exposing the port so that the container will send out it's information across the network. 
EXPOSE 6600


