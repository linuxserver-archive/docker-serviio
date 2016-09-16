FROM lsiobase/alpine
MAINTAINER sparklyballs

# package version
ARG SERVIIO_VER="1.7"

# environment settings
ENV JAVA_HOME="/usr/bin/java"

# install packages
RUN \
 apk add --no-cache \
	ffmpeg \
	jasper \
	jpeg \
	lcms2 \
	openjdk8-jre

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	gcc \
	g++ \
	jasper-dev \
	jpeg-dev \
	lcms2-dev \
	tar && \

# install serviio app
 mkdir -p \
	/app/serviio && \
 curl -o \
 /tmp/serviio.tar.gz -L \
	http://download.serviio.org/releases/serviio-$SERVIIO_VER-linux.tar.gz && \
 tar xf /tmp/serviio.tar.gz -C \
	/app/serviio --strip-components=1 && \

# fetch dcraw
 curl -o \
 /usr/bin/dcraw.c -L \
	http://www.cybercom.net/~dcoffin/dcraw/dcraw.c && \

# compile dcraw
 cd /usr/bin && \
 gcc -o dcraw -O4 dcraw.c -lm -ljasper -ljpeg -llcms2 && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# change abc home folder
RUN \
 usermod -d /config/serviio abc

# add local files
COPY root/ /

# ports and volumes
EXPOSE 23423/tcp 23424/tcp 8895/tcp 1900/udp
VOLUME /config /transcode
