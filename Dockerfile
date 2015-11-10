FROM linuxserver/baseimage.apache

MAINTAINER Sparklyballs <sparklyballs@linuxserver.io>

ENV BUILD_APTLIST="build-essential checkinstall cmake cmake-curses-gui mercurial texi2html yasm zlib1g-dev"

ENV APTLIST="dcraw git libass-dev libfaac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libssl1.0.0 libssl-dev libtheora-dev libva-dev libvorbis-dev libx11-dev libxfixes-dev libxvidcore4 libxvidcore-dev libvdpau-dev oracle-java8-installer php5-xmlrpc unzip wget"

# set serviio version, java and location ENV
ENV SERVIIO_VER="1.5.2" JAVA_HOME="/usr/lib/jvm/java-8-oracle" LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Set the locale
RUN locale-gen en_US.UTF-8 && \

# repositories
add-apt-repository -y ppa:webupd8team/java && \
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

# install serviio app
RUN mkdir -p /app/serviio && \
curl  -o /tmp/serviio.tar.gz -L http://download.serviio.org/releases/serviio-$SERVIIO_VER-linux.tar.gz && \
tar xvf /tmp/serviio.tar.gz -C /app/serviio --strip-components=1 && \
mv /app/serviio/plugins /app/serviio/plugins_orig && \

# install build packages
apt-get update && \
apt-get install $APTLIST $BUILD_APTLIST -qy && \

# clone source codes
git clone git://git.videolan.org/x264 /tmp/x264 && \
git clone git://git.ffmpeg.org/rtmpdump /tmp/rtmpdump && \
hg clone http://hg.videolan.org/x265 /tmp/x265 && \
git clone --depth 1 git://git.videolan.org/ffmpeg /tmp/ffmpeg && \
git clone https://github.com/webmproject/libvpx/ /tmp/libvpx && \

# compile x264
cd /tmp/x264 && \
./configure --enable-static --disable-opencl && \
make && \
checkinstall --pkgname=x264 --pkgversion="3:$(./version.sh | awk -F'[" ]' '/POINT/{print $4"+git"$5}')" --backup=no --deldoc=yes --fstrans=no --default && \

# compile rtmpdump
cd /tmp/rtmpdump && \
make SYS=posix && \
checkinstall --pkgname=rtmpdump --pkgversion="2:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default && \

# compile libvpx
cd /tmp/libvpx && \
./configure && \
make && \
checkinstall --pkgname=libvpx --pkgversion="1:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default && \

# compile x265
cd /tmp/x265/build && \
cmake ../source && \
make && \
make install && \
cd /lib && \
ln -s /usr/local/lib/libx265.so.75 && \

# compile ffmpeg
cd /tmp/ffmpeg && \
./configure --enable-gpl \
--enable-libfaac \
--enable-libmp3lame \
--enable-libopencore-amrnb \
--enable-libopencore-amrwb \
--enable-libtheora \
--enable-libvorbis \
--enable-libx264 \
--enable-nonfree \
--enable-postproc \
--enable-version3 \
--enable-x11grab \
--enable-librtmp \
--enable-libxvid \
--enable-libass \
--enable-libx265 \
--enable-postproc \
--enable-libvpx && \
make && \
checkinstall --pkgname=ffmpeg --pkgversion="99:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default && \

# compile x264 lavf support
apt-get remove x264 -y && \
cd /tmp/x264 && \
rm *.deb && \
make distclean && \
./configure \
--enable-static \
--enable-lavf \
--disable-opencl && \
make && \
checkinstall --pkgname=x264 --pkgversion="3:$(./version.sh | awk -F'[" ]' '/POINT/{print $4"+git"$5}')" --backup=no --deldoc=yes --fstrans=no --default && \
echo "include /usr/local/lib/" >>  /etc/ld.so.conf && \
ldconfig && \

# remove build packages and check reinstall runtimes
apt-get purge --remove $BUILD_APTLIST -y && \
apt-get autoremove -y && \
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
