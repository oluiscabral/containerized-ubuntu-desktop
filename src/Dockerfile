FROM ubuntu:24.04
LABEL maintainer=oluiscabral

ENV REMOTE_USER='myuser'
## NOTE: Password must be at least 6 characters
ENV REMOTE_PASS='mypassword'

ENV DEBIAN_FRONTEND=noninteractive
ENV HTTPS_CERT=/etc/ssl/certs/ssl-cert-snakeoil.pem
ENV HTTPS_CERT_KEY=/etc/ssl/private/ssl-cert-snakeoil.key
ENV VGL_DISPLAY=egl
ENV VNC_THREADS=2

## INSTALL COMMON TOOLS
RUN apt-get update -y && apt-get install -y \
    sudo \
    vim \
    gedit \
    locales \
    gnupg2 \
    wget \
    curl \
    zip \
    lsb-release \
    bash-completion \
    net-tools \
    iputils-ping \
    mesa-utils \
    software-properties-common \
    build-essential \
    python3 \
    python3-pip \
    python3-numpy \
    openssh-server \
    openssl \
    git \
    git-lfs \
    tmux &&\
    apt-get clean -y &&\
    rm -rf /var/lib/apt/lists/*

## INSTALL DESKTOP
RUN add-apt-repository -y ppa:mozillateam/ppa &&\
    mkdir -p /etc/apt/preferences.d &&\
    echo "Package: firefox*\n\
Pin: release o=LP-PPA-mozillateam\n\
Pin-Priority: 1001" > /etc/apt/preferences.d/mozilla-firefox &&\
    apt-get update -y && apt-get install -y \
    xfce4 \
    terminator \
    ffmpeg \
    firefox \
    dbus-x11 &&\
    apt-get remove -y xfce4-screensaver --purge &&\
    update-alternatives --set x-www-browser /usr/bin/firefox &&\
    apt-get clean -y &&\
    rm -rf /var/lib/apt/lists/*

## INSTALL PULSEAUDIO
ENV DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
RUN apt-get update -y && apt-get install -y pulseaudio && mkdir -p /var/run/dbus &&\
    apt-get clean -y &&\
    rm -rf /var/lib/apt/lists/*

## CONFIGURE SSH 
RUN mkdir -p /var/run/sshd &&\
    sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config &&\
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

## INSTALL KASMVNC
RUN curl -fSL "https://github.com/kasmtech/KasmVNC/releases/download/v1.3.3/kasmvncserver_noble_1.3.3_"$(dpkg --print-architecture)".deb" -o /tmp/kasmvncserver.deb &&\
    apt-get update -y && apt-get install -y /tmp/kasmvncserver.deb &&\
    rm /tmp/kasmvncserver.deb &&\
    sed -i 's/exec xfce4-session/xset s off;&/' /usr/lib/kasmvncserver/select-de.sh &&\
    apt-get clean -y &&\
    rm -rf /var/lib/apt/lists/*

## START SERVICES
COPY "config/entrypoint.sh" "/sbin/entrypoint.sh"
EXPOSE 22 4000
ENTRYPOINT ["/sbin/entrypoint.sh"]
