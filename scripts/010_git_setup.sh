#!/bin/bash

HOME="/home/docker"
if [ ! -z "$GITEMAIL" ]; then
    /sbin/setuser docker git config --global user.email "$GITEMAIL"
fi
if [ ! -z "$GITNAME" ]; then
    /sbin/setuser docker git config --global user.name "$GITNAME"
fi
/sbin/setuser docker git config --global push.default simple

