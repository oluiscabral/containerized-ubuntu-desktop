#!/bin/bash

sudo docker build \
    --tag ubuntu-desktop \
    --build-arg UNPRIVILEGED_USER=ergoserv \
    --build-arg UNPRIVILEGED_USER_PASS=1234 \
    .

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
    ubuntu-desktop
