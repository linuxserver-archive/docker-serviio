FROM linuxserver/baseimage.apache

MAINTAINER Sparklyballs <sparklyballs@linuxserver.io>

ENV BUILD_APTLIST=\
"build-essential checkinstall git libfaac-dev libjack-jackd2-dev \
libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev \
libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev texi2html zlib1g-dev \
libssl1.0.0 libssl-dev libxvidcore-dev libxvidcore4 libass-dev cmake mercurial"


ENV APTLIST="apache2 git-core  php5 php5-curl php5-xmlrpc oracle-java8-installer dcraw"

# set serviio version, java and location ENV
ENV SERVIIO_VER="1.5.2" JAVA_HOME="/usr/lib/jvm/java-8-oracle" LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Set the locale
RUN locale-gen en_US.UTF-8

# install serviio app and curl source code
RUN mkdir -p /app/serviio && \
mkdir -p /tmp/rtmpdump && \
mkdir -p /tmp/yasm && \
mkdir -p /tmp/cmake/build  && \
curl  -o /tmp/serviio.tar.gz -L http://download.serviio.org/releases/serviio-$SERVIIO_VER-linux.tar.gz && \
curl -o /tmp/rtmpdump.tar.gz -L  http://download.serviio.org/opensource/rtmpdump.tar.gz && \
curl -o /tmp/yasm1.tar.gz  -L http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz && \
curl -o /tmp/cmake3.tar.gz -L http://www.cmake.org/files/v3.1/cmake-3.1.2.tar.gz && \
tar xvf /tmp/serviio.tar.gz -C /app/serviio --strip-components=1 && \
tar xvf /tmp/rtmpdump.tar.gz -C /tmp/rtmpdump --strip-components=1 && \
tar xvf /tmp/yasm1.tar.gz -C /tmp/yasm --strip-components=1 && \
tar xvf /tmp/cmake3.tar.gz -C /tmp/cmake --strip-components=1 && \
mv /app/serviio/plugins /app/serviio/plugins_orig && \

# install build packages
apt-get update && \
apt-get install $BUILD_APTLIST -qy && \

# clone source codes
git clone https://github.com/FFmpeg/FFmpeg /tmp/ffmpeg && \
git clone git://git.videolan.org/x264 /tmp/x264 && \
hg clone http://hg.videolan.org/x265 /tmp/x265 && \
git clone https://chromium.googlesource.com/webm/libvpx /tmp/libvpx && \

# compile yasm
cd /tmp/yasm && \
./configure && \
make && \
checkinstall --pkgname=yasm --pkgversion="1.3.0" --backup=no --deldoc=yes --fstrans=no --default && \

# compile cmake
cd /tmp/cmake/build && \
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr && \
make && \
make install && \
ldconfig && \

# compile x264
cd /tmp/x264 && \
./configure --enable-static --disable-opencl && \
make && \
checkinstall --pkgname=x264 --pkgversion="3:$(./version.sh | \
awk -F'[" ]' '/POINT/{print $4"+git"$5}')" --backup=no --deldoc=yes \
--fstrans=no --default && \

# compile rtmpdump
cd /tmp/rtmpdump && \
make && \
make install && \

# compile libvpx
cd /tmp/libvpx && \
./configure && \
make && \
checkinstall --pkgname=libvpx --pkgversion="1:$(date +%Y%m%d%H%M)-git" --backup=no \
    --deldoc=yes --fstrans=no --default && \

# compile x265
cd /tmp/x265/build && \
cmake ../source && \
make && \
make install && \
cd /lib && \
ln -s /usr/local/lib/libx265.so.75 && \

# compile ffmpeg
cd /tmp/ffmpeg && \
./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb \
    --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 \
    --enable-nonfree --enable-postproc --enable-version3 --enable-x11grab --enable-librtmp \
    --enable-libxvid --enable-libass --enable-libx265 --enable-libvpx && \
make && \
make install && \

# compile x264 lavf support
apt-get remove x264 -y && \
cd /tmp/x264 && \
rm *.deb && \
make distclean && \
./configure \
--enable-static \
--disable-opencl && \
make && \
make install && \

# remove build packages and install runtimes
apt-get purge --remove $BUILD_APTLIST -y && \
apt-get autoremove -y && \

# cleanup
cd /tmp && \
apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# instal runtime packages
RUN add-apt-repository -y ppa:webupd8team/java && \
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

RUN apt-get update -q && \
apt-get install $APTLIST -qy && \

# cleanup
cd /tmp && \
apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

#Adding Custom files
ADD defaults/ /defaults/
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run && chmod -v +x /etc/my_init.d/*.sh && \

# give abc user a home folder
usermod -d /config/serviio abc

# ports and volumes
EXPOSE 23424/tcp 8895/tcp 1900/udp 8780/tcp
VOLUME /config /transcode
