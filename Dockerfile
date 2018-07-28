FROM debian:buster
RUN echo 'deb-src http://ftp.debian.org/debian buster main' >> /etc/apt/sources.list
#RUN echo 'deb-src http://ftp.debian.org/debian sid main' >> /etc/apt/sources.list
#RUN echo 'Package: *' >> /etc/apt/preferences.d/be-stable
#RUN echo 'Pin: release a=stable-backports' >> /etc/apt/preferences.d/be-stable
#RUN echo 'Pin-Priority: 100' >> /etc/apt/preferences.d/be-stable
#RUN echo 'Package: *' >> /etc/apt/preferences.d/be-stable
#RUN echo 'Pin: release a=stable' >> /etc/apt/preferences.d/be-stable
#RUN echo 'Pin-Priority: 999' >> /etc/apt/preferences.d/be-stable
RUN apt-get update
RUN apt-get install -y clang-6.0 lld-6.0 llvm-6.0-dev python-jinja2 \
	gsettings-desktop-schemas-dev xvfb libre2-dev libelf-dev libvpx-dev \
	libkrb5-dev libexif-dev libsrtp-dev libxslt1-dev libpam0g-dev \
	libsnappy-dev libavutil-dev libavcodec-dev libavformat-dev libjsoncpp-dev \
	libspeechd-dev libminizip-dev libhunspell-dev libopenjp2-7-dev \
	libmodpbase64-dev libnss3-dev libnspr4-dev libcups2-dev libjs-jquery-flot \
	make ninja-build wget flex yasm wdiff gperf bison valgrind x11-apps \
	libglew-dev libgl1-mesa-dev libglu1-mesa-dev libegl1-mesa-dev \
	libgles2-mesa-dev mesa-common-dev libxt-dev libgbm-dev libxss-dev \
	libpci-dev libcap-dev libdrm-dev libflac-dev libudev-dev libopus-dev \
	libwebp-dev libxtst-dev libgtk-3-dev liblcms2-dev libpulse-dev \
    libasound2-dev libusb-1.0-0-dev libevent-dev libgcrypt20-dev libva-dev \
    libvpx-dev debhelper libglew-dev
RUN apt-get build-dep -y chromium
RUN adduser --disabled-password --gecos 'ungoogler,,,,' ungoogler
RUN mkdir -p /home/ungoogler/build
ADD https://github.com/Eloston/ungoogled-chromium/archive/67.0.3396.87-2.tar.gz /home/ungoogler/67.tar.gz
RUN cd /home/ungoogler/ && \
    tar xvzf /home/ungoogler/67.tar.gz && \
    cp -r /home/ungoogler/ung*/* /home/ungoogler/build/
COPY resources/config_bundles/proxy_i2p/ /home/ungoogler/build/resources/config_bundles/proxy_i2p/
COPY resources/patches/i2p/ /home/ungoogler/build/resources/patches/i2p/
COPY Makefile /home/ungoogler/build/
COPY . /home/ungoogler/build
RUN chown -R ungoogler:ungoogler /home/ungoogler/build
USER ungoogler
WORKDIR /home/ungoogler/build
RUN ls
CMD make build-deb
