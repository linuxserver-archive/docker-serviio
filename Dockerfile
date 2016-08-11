FROM lsiobase/xenial
MAINTAINER sparklyballs

# package version
ARG SERVIIO_VER="1.6.1"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV JAVA_HOME="/usr/bin/java" \
LANG=en_US.UTF-8 LANGUAGE=en_US:en

# Set the locale
RUN \
 locale-gen en_US.UTF-8 && \

# install packages
 apt-get update && \
 apt-get install -y \
	dcraw \
	default-jre \
	ffmpeg && \

# install serviio app
 mkdir -p \
	/app/serviio && \
 curl -o \
 /tmp/serviio.tar.gz -L \
	http://download.serviio.org/releases/serviio-$SERVIIO_VER-linux.tar.gz && \
 tar xf /tmp/serviio.tar.gz -C \
	/app/serviio --strip-components=1 && \

# cleanup
 apt-get clean && \
	rm -rf /tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# change abc home folder
RUN \
 usermod -d /config/serviio abc

# add local files
COPY root/ /

# ports and volumes
EXPOSE 23423/tcp 23424/tcp 8895/tcp 1900/udp
VOLUME /config /transcode
