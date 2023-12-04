FROM ubuntu:20.04

ARG LINUXDEPLOYQT_VERSION=continuous
ARG QT=5.15.2
ARG QT_MODULES=all
ARG QT_HOST=linux
ARG QT_TARGET=desktop

RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    git \
    cmake \
    python3 \
    python3-pip \
    openssh-client \
    ca-certificates \
    locales \
    sudo \
    curl \
    build-essential \
    pkg-config \
    libgl1-mesa-dev \
    libsm6 \
    libice6 \
    libxext6 \
    libxrender1 \
    libxkbcommon-x11-0 \
    libfontconfig1 \
    libdbus-1-3 \
    libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-xinerama0 \
    file \
    fuse \
    libsdl2-2.0-0 \
    libusb-1.0-0 \
    libavcodec58 \
    doxygen graphviz doxyqml \
    zip \
    libopencv-dev libopencv-imgcodecs-dev libopencv-imgproc-dev \
    gstreamer1.0-gtk3 libpulse-mainloop-glib0 \
    cppcheck lsb-release \
    libxcb-randr0 libxcb-shape0 \
    libpulse-dev \
    libelf-dev libdwarf-dev\
    libdlt2 libdlt-dev \
    libwebp-dev \
    libxkbcommon-dev \
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

# Install Qt
RUN pip3 install aqtinstall
RUN aqt install-qt --outputdir /opt/qt ${QT_HOST} ${QT_TARGET} ${QT} gcc_64 --modules ${QT_MODULES}
ENV PATH /opt/qt/${QT}/gcc_64/bin:$PATH
ENV QT_PLUGIN_PATH /opt/qt/${QT}/gcc_64/plugins/
ENV QML_IMPORT_PATH /opt/qt/${QT}/gcc_64/qml/
ENV QML2_IMPORT_PATH /opt/qt/${QT}/gcc_64/qml/

# Install linuxdeployqt
RUN mkdir -p /usr/local/bin \
    && curl -Lo/usr/local/bin/linuxdeployqt "https://github.com/probonopd/linuxdeployqt/releases/download/$LINUXDEPLOYQT_VERSION/linuxdeployqt-$LINUXDEPLOYQT_VERSION-x86_64.AppImage" \
    && chmod a+x /usr/local/bin/linuxdeployqt

# Build QtMQTT module
RUN git clone https://code.qt.io/qt/qtmqtt.git -b ${QT} &&\
    cd qtmqtt && [ -f *.pro ] && qmake || cmake . && make -j4 && make install &&\
    cd .. && rm -rf qtmqtt
    
# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# Add group & user + sudo
RUN groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user
USER user
WORKDIR /home/user
ENV HOME /home/user
