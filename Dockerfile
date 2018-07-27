FROM debian:sid
RUN apt-get update
RUN apt-get install -y -t stretch-backports clang-6.0 lld-6.0 llvm-6.0-dev python-jinja2 \
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
    libvpx-dev
RUN apt-get install -y -t debhelper
RUN adduser --disabled-password --gecos 'ungoogler,,,,' ungoogler
COPY . /home/ungoogler/build
RUN chown -R ungoogler:ungoogler /home/ungoogler/build
USER ungoogler
WORKDIR /home/ungoogler/build
RUN ls
CMD make build-deb
