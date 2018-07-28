
deriv?=linux_portable
deb_deriv?=buster

WD=$(PWD)

usei2p=i2p_

docker-build: update docker
	docker rm -f ungoogled-chromium; true
	docker run -t -i \
		--name ungoogled-chromium \
		eyedeekay/ungoogled-chromium

update:
	git pull --force

setup:
	mkdir -p "buildspace-$(use_i2p)$(deriv)/downloads"
	ln -sf buildspace-$(use_i2p)$(deriv) buildspace
	./buildkit-launcher.py genbun $(usei2p)$(usedeb)$(deriv)
	./buildkit-launcher.py getsrc
	./buildkit-launcher.py subdom

gen: ungen
	cp -r resources/config_bundles/debian_buster resources/config_bundles/i2p_debian_buster
	cp -r resources/config_bundles/debian_stretch resources/config_bundles/i2p_debian_stretch
	cp -r resources/config_bundles/ubuntu_bionic resources/config_bundles/i2p_ubuntu_bionic
	cp -r resources/config_bundles/windows resources/config_bundles/i2p_windows
	cp -r resources/config_bundles/macos resources/config_bundles/i2p_macos
	cp -r resources/config_bundles/archlinux resources/config_bundles/i2p_archlinux
	cp -r resources/config_bundles/opensuse resources/config_bundles/i2p_opensuse
	cp -r resources/config_bundles/linux_portable resources/config_bundles/i2p_linux_portable
	find resources/config_bundles/i2p_*/ -name *.ini -exec sed -i 's|depends = |depends = proxy_i2p,|g' {} \;
	find resources/config_bundles/i2p_*/ -name *.ini -exec sed -i 's|common,|common|g' {} \;
	find resources/config_bundles/i2p_*/ -name *.ini -exec sed -i 's|display_name =|display_name = i2p Browser|g' {} \;
	find resources/config_bundles/proxy_i2p/ -name *.ini -exec sed -i 's|display_name =|display_name = i2p Browser|g' {} \;

ungen:
	/bin/rm -rf resources/config_bundles/i2p_*
	find resources/config_bundles/ -name *.ini -exec sed -i 's|proxy_i2p,||g' {} \;
	find resources/config_bundles/ -name *.ini -exec sed -i 's|proxy_i2p||g' {} \;
	find resources/config_bundles/ -name *.ini -exec sed -i 's|i2p Browser||g' {} \;
	find resources/config_bundles/ -name *.ini -exec sed -i 's|common,|common|g' {} \;

patchset:
	rm -rf buildspace/tree2
	cp -r buildspace-$(use_i2p)$(deriv)/tree/ buildspace-$(use_i2p)$(deriv)/tree2/
	find buildspace-$(use_i2p)$(deriv)/tree/chrome/browser/ui/ -name *.cc -exec sed -i 's|kWebRTCNonProxiedUdpEnabled, true|kWebRTCNonProxiedUdpEnabled, false|g' {} \;
	diff -Npur ./buildspace/tree2/chrome ./buildspace/tree/chrome | tee $(WD)/resources/patches/i2p/default_proxy.patch

build-deb: gen
	usedeb=debian_ deriv=$(deb_deriv)	make setup; true
	mkdir -p buildspace-$(use_i2p)$(deb_deriv)/downloads
	ln -sf buildspace-$(use_i2p)$(deb_deriv) buildspace
	/bin/rm -rf ./buildspace/tree/debian
	./buildkit-launcher.py genpkg debian --flavor $(deb_deriv)
	cd buildspace/tree && \
		dpkg-buildpackage -b -uc

build: gen
	mkdir -p buildspace-$(use_i2p)$(deriv)/downloads
	ln -sf buildspace-$(use_i2p)$(deriv) buildspace
	./buildkit-launcher.py genpkg linux_simple
	cd buildspace/tree && \
		./ungoogled_packaging/build.sh && \
		./ungoogled_packaging/package.sh

clean:
	/bin/rm -fr buildspace-$(use_i2p)$(deriv) buildspace*

clean-deb:
	deriv=$(deb_deriv) make clean

deps:
	apt-get install -y debhelper clang-6.0 lld-6.0 llvm-6.0-dev python-jinja2 \
		gsettings-desktop-schemas-dev xvfb libre2-dev libelf-dev libvpx-dev \
		libkrb5-dev libexif-dev libsrtp-dev libxslt1-dev libpam0g-dev \
		libsnappy-dev libavutil-dev libavcodec-dev libavformat-dev libjsoncpp-dev \
		libspeechd-dev libminizip-dev libhunspell-dev libopenjp2-7-dev \
		libmodpbase64-dev libnss3-dev libnspr4-dev libcups2-dev libjs-jquery-flot \
		make ninja-build wget flex yasm wdiff gperf bison valgrind x11-apps \
		libglew-dev libgl1-mesa-dev libglu1-mesa-dev libegl1-mesa-dev \
		libgles2-mesa-dev mesa-common-dev libxt-dev libgbm-dev libxss-dev \
		libpci-dev libcap-dev libdrm-dev libflac-dev libudev-dev libopus-dev \
		libwebp-dev libxtst-dev libgtk-3-dev liblcms2-dev libpulse-dev libasound2-dev \
		libusb-1.0-0-dev libevent-dev libgcrypt20-dev libva-dev

docker:
	docker build -f Dockerfile -t eyedeekay/ungoogled-chromium .

