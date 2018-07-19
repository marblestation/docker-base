#!/bin/bash
VHOST_USER=marble
VHOST_IP=$(route | awk '/default/ { print $2   }')
mkdir -p $HOME/remote/vhost
sshfs -o allow_root,uid=1000,gid=1000 ${VHOST_USER}@${VHOST_IP}:/Users/${VHOST_USER} $HOME/remote/vhost
