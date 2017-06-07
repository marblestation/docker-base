#!/bin/bash

if [ ! -z "$GITEMAIL" ]; then
    git config --global user.email "$GITEMAIL"
fi
if [ ! -z "$GITNAME" ]; then
    git config --global user.name "$GITNAME"
fi
git config --global push.default simple

/bin/bash
