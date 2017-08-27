#!/bin/bash

HOME="/home/ubuntu"
if [ ! -z "$GITEMAIL" ]; then
    /sbin/setuser ubuntu git config --global user.email "$GITEMAIL"
fi
if [ ! -z "$GITNAME" ]; then
    /sbin/setuser ubuntu git config --global user.name "$GITNAME"
fi
/sbin/setuser ubuntu git config --global push.default simple

