FROM ubuntu:latest

MAINTAINER petr.ruzicka@gmail.com

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
    && apt-get update \
    && apt-get install -y -qq --no-install-recommends \
         build-essential \
         ca-certificates \
         cmake \
         curl \
         exiftran \
         imagemagick \
         jpegoptim \
         libcpanel-json-xs-perl \
         libimage-exiftool-perl \
         libjpeg-dev \
         liblcms2-utils \
         libpng-dev \
         libtiff-dev \
         opencv-data \
         p7zip \
         perl \
         pngcrush \
         python3-dev \
         python3-numpy \
         unzip \
         zip \
    && curl -s https://codeload.github.com/opencv/opencv/zip/master > /master.zip \
    && unzip -q /master.zip \
    && mkdir /opencv-master/cmake_binary \
    && cd /opencv*/cmake_binary \
    && cmake \
         -D ENABLE_PRECOMPILED_HEADERS=OFF \
         -D CMAKE_INSTALL_PREFIX=/usr/ \
         -D CMAKE_BUILD_TYPE=MINSIZEREL \
         -D BUILD_DOCS=OFF \
         -D BUILD_TESTS=OFF \
         -D BUILD_PERF_TESTS=OFF \
         -D WITH_OPENCL=OFF \
         -D WITH_V4L=OFF \
         -D BUILD_WITH_DEBUG_INFO=OFF \
         -D BUILD_opencv_apps=OFF \
         -D WITH_IPP=OFF \
         -D BUILD_opencv_video=OFF \
         -D BUILD_opencv_videoio=OFF \
         -D BUILD_opencv_calib3d=OFF \
         -D BUILD_opencv_highgui=OFF \
         -D BUILD_opencv_calib3d=OFF \
         -D BUILD_opencv_ts=OFF \
         .. \
    && make install -j $(nproc) \
    && mv /usr/share/OpenCV /usr/share/opencv \
    && curl -s https://codeload.github.com/wavexx/facedetect/zip/master > /master.zip \
    && unzip -q -p /master.zip facedetect-master/facedetect > /usr/bin/facedetect \
    && chmod +x /usr/bin/facedetect \
    && apt-get purge -y -qq \
         build-essential \
         ca-certificates \
         cmake \
         curl \
         libjpeg-dev \
         libpng-dev \
         libtiff-dev \
         python3-dev \
         unzip \
    && apt-get autoremove -y -qq \
    && apt-get clean -y -qq all \
    && rm -rf /opencv* /master.zip /var/lib/apt/lists/* /usr/share/doc /usr/share/locale /usr/share/man

VOLUME /mnt

WORKDIR /mnt

ENTRYPOINT ["sitelen-mute"]
