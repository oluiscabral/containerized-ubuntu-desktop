FROM ubuntu:24.10
MAINTAINER oluiscabral

ARG USER="ergoserv"
ARG PASS="1234"

ENV DEBIAN_FRONTEND=noninteractive

# INSTALL LOCALE
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales && \
    echo "$LANG UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# INSTALL SYSTEMMD
RUN apt-get update && apt-get install -y \
    dbus \
    dbus-x11 \
    systemd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    dpkg-divert --local --rename --add /sbin/udevadm && \
    ln -s /bin/true /sbin/udevadm
VOLUME ["/sys/fs/cgroup"]
STOPSIGNAL SIGRTMIN+3
CMD [ "/sbin/init" ]

# INSTALL GNOME
RUN apt-get update && apt-get install -y \
    ubuntu-desktop \
    fcitx-config-gtk \
    gnome-tweak-tool \
    gnome-usage && \
    apt-get purge -y --autoremove gnome-initial-setup && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# REMOVE UNNECESSARY SYSTEM TARGETS
RUN rm -f \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp* \
    /lib/systemd/system/systemd-resolved.service

# INSTALL TIGERVNC SERVER
RUN apt-get update && apt-get install -y \
    tigervnc-common \
    tigervnc-scraping-server \
    tigervnc-standalone-server \
    tigervnc-viewer \
    tigervnc-xorg-extension && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY tigervnc@.service /etc/systemd/system/tigervnc@.service
RUN sed -i 's/default/${USER}/g' /etc/systemd/system/tigervnc@.service
RUN systemctl enable tigervnc@:1
EXPOSE 5901

# INSTALL NOVNC
RUN apt-get update && apt-get install -y \
    net-tools \
    novnc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/share/novnc/vnc_lite.html /usr/share/novnc/index.html
COPY novnc.service /etc/systemd/system/novnc.service
RUN sed -i 's/default/${USER}/g' /etc/systemd/system/novnc.service
RUN systemctl enable novnc
EXPOSE 6901

# CREATE UNPRIVILEGED USER
RUN useradd "${USER}" -U -m -d "/home/${USER}" -s /bin/bash
RUN apt-get update && apt-get install -y \
    sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${USER}" && \
    chmod 440 "/etc/sudoers.d/${USER}"
USER "${USER}"
ENV USER="${USER}"
ENV HOME="/home/${USER}"
WORKDIR "/home/${USER}"

# SET UP VNC
RUN mkdir -p $HOME/.vnc
COPY xstartup $HOME/.vnc/xstartup
RUN echo "${PASS}" | vncpasswd -f >> $HOME/.vnc/passwd && chmod 600 $HOME/.vnc/passwd

# SWITCH BACK TO ROOT TO START SYSTEMD
USER root
