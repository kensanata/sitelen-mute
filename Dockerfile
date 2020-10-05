FROM ubuntu:latest

MAINTAINER alex@gnu.org

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
    && apt-get update \
    && apt-get install -y -qq --no-install-recommends \
         imagemagick \
         liblcms2-utils \
         exiftran \
         p7zip \
         perl \
         libimage-exiftool-perl \
	 libcpanel-json-xs-perl \
         jpegoptim \
	 pngcrush \
	 facedetect \
    && apt-get clean -y -qq all \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/locale /usr/share/man

VOLUME /mnt

WORKDIR /mnt

ENTRYPOINT ["sitelen-mute"]
