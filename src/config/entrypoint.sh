#!/bin/sh
update-alternatives --install /usr/bin/python python /usr/bin/python3 2
env | grep -Ev "CMD=|PWD=|SHLVL=|_=|DEBIAN_FRONTEND=|USER=|HOME=|UID=|GID=|PASSWORD=|REMOTE_USER=|REMOTE_PASS=" > /etc/environment

useradd $REMOTE_USER -U -m -d /home/$REMOTE_USER -s /bin/bash
echo "root:$REMOTE_PASS" | chpasswd
echo "$REMOTE_USER:$REMOTE_PASS" | chpasswd
usermod -aG sudo $REMOTE_USER
usermod -aG ssl-cert $REMOTE_USER

/usr/sbin/sshd
/etc/init.d/dbus start

su $REMOTE_USER -c "echo -e \"$REMOTE_PASS\n$REMOTE_PASS\n\" | kasmvncpasswd -u $REMOTE_USER -o -w -r"
rm -rf /tmp/.X1000-lock /tmp/.X11-unix/X1000
su $REMOTE_USER -c "kasmvncserver :1000 -select-de xfce -interface 0.0.0.0 -websocketPort 4000 -cert $HTTPS_CERT -key $HTTPS_CERT_KEY -RectThreads $VNC_THREADS"
su $REMOTE_USER -c "pulseaudio --start"
unset REMOTE_PASS
tail -f /home/$REMOTE_USER/.vnc/*.log
