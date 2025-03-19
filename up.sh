#!/bin/bash

sudo docker build -t oluiscabral/ubuntu-desktop .
sudo docker run \
    --rm \
    --detach \
    --name=ubuntu-desktop \
    --tmpfs /run \
    --tmpfs /tmp \
    --tmpfs /run/lock \
    --volume /sys/fs/cgroup:/sys/fs/cgroup \
    --cap-add SYS_BOOT \
    --cap-add SYS_ADMIN \
    --publish 5901:5901 \
    --publish 6901:6901 \
    --cgroupns=host \
    oluiscabral/ubuntu-desktop
