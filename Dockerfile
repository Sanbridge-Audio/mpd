#Start dockerfile by creating all the dependencies needed.
ARG VERSION=stable
FROM debian:${VERSION} AS depend
LABEL maintainer="Matt Dickinson" 
 
#Installation of all of the dependencies needed to build Music Player Daemon from source.  
RUN apt-get update && apt-get install -y \
	curl \
	git \
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
	libboost-dev \
	meson \
	nano \
	ninja-build \
	wget \
	xz-utils \
	&& apt-get clean && rm -fR /var/lib/apt/lists/*

#Setting a new stage for the dockerfile so that the cache can be utilized and the build can be sped up.
FROM depend AS mpdbuild

#Set the working directory of the dockerfile at this stage.
ENV HOME /root

RUN git clone https://github.com/MusicPlayerDaemon/MPD

#Change the working directory to MPD for installation.
WORKDIR MPD

#Installation of MPD
RUN meson . output/release --buildtype=debugoptimized -Db_ndebug=true 
RUN ninja -C output/release
RUN ninja -C output/release install

#Changing stage for the dockerfile to the configuration of MPD.
FROM debian:stable-slim AS config



COPY --from=mpdbuild /usr/local/bin/mpd /usr/local/bin

#RUN apt-get update && apt-get install -y \
RUN apt-get update && apt-get -y install --no-install-recommends \
	flac \
	libdbus-1-3 \
	libmpdclient-dev \
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
	mosquitto-clients \
	vorbis-tools \
	&& apt-get clean && rm -fR /var/lib/apt/lists/*

#Make needed directories. Should match the config file.
RUN  mkdir -p /var/lib/mpd/music \
  && mkdir -p ~/.mpd \
	&& mkdir -p ~/.mpd/playlists \
	&& mkdir -p ~/.config/mpd \
	&& mkdir -p /opt/appdata \
	&& chmod 777 ~/.mpd
	#	&& chmod a+w ~/.mpd/playlists

#Create music, playlist, tmp (for sending audio to snapcast) and config folder.
VOLUME /var/lib/mpd/music /.mpd/playlists /tmp /usr/local/etc

#Creating databases.
RUN touch /.mpd/mpd.log \
	&& touch /.mpd/sticker.sql \
	&& touch /.mpd/pid \
	&& touch /.mpd/mpdstate \
	&& touch /.mpd/tag_cache

#Add permissions to created databases
RUN chmod 777 /.mpd/mpd.log \
	&& chmod 777 /.mpd/sticker.sql \
	&& chmod 777 /.mpd/pid \
#	&& chown 777 /.mpd/pid \
	&& chmod 777 /.mpd/mpdstate \
	&& chmod 777 /.mpd/tag_cache

#Copy preset configuration file into image from folder. 
COPY mpd.conf /usr/local/etc

#Add permissions so that the configuration file will actually work
RUN chmod 777 /usr/local/etc/mpd.conf
#RUN ln -s /usr/local/etc/mpd.conf /opt/appdata

#Copy a services file that will allow MPD to find the mpd.conf file. 
COPY mpd.service /usr/local/lib/systemd/system 

#Copy stations playlist into mpd playlists folder that was created earlier.
COPY Stations.m3u /.mpd/playlists 

FROM config as mpd
#ARG USERNAME=matt
ARG USER_UID=1000
#ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

ENV TZ="America/New_York"


#RUN date > /root/tmp_variable


#Consistent command across multiple types of mpd dockerfiles.
#CMD ["--stdout", "--no-daemon"]
#ENTRYPOINT ["mpd"]

CMD mpd --stdout --no-daemon

#Exposing the port so that the container will send out it's information across the network. 
EXPOSE 6600 8801

