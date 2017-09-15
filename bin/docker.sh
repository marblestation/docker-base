#!/bin/bash

# Edit:
GITNAME="John Smith" 
GITEMAIL="jsmith@users.noreply.github.com"

STATUS=$(docker inspect --format="{{ .State.Status  }}" base 2>/dev/null )
if [ $? -eq 0 ]; then
    if [[ ${STATUS} = "exited" ]]; then
        echo -e "\n>>> Deleting container."
        docker rm base > /dev/null
    elif [[ ${STATUS} = "running" ]]; then
        echo -e "\n>>> Stopping container."
        docker stop base > /dev/null
        echo -e "\n>>> Deleting container."
        docker rm base > /dev/null
    fi
fi

set -e
echo -e "\n>>> Building image."
docker build -t marblestation/base .
echo -e "\n>>> Running container."
DOCKER_USERNAME="ubuntu"

if [[ "$PLATFORM" == 'Darwin' ]]; then
    DOCKER_IP=$(ifconfig $(route -n get default |grep interface|cut -f 2 -d ':') | grep inet | awk '$1=="inet" {print $2}')
    xhost + $DOCKER_IP
    DISPLAY=$DOCKER_IP:0
    NETWORK_PARAMS="-p 127.0.0.1:8888:8888" # net host does not work in mac as in linux and it is not required for X11 apps, ports should be implicitly exposed
else
    NETWORK_PARAMS="--net=host" # X11 apps requires net host, also all ports will be automatically exposed
fi
docker run -d \
        --name base \
        --hostname $HOSTNAME \
        $NETWORK_PARAMS \
        --device /dev/fuse --cap-add SYS_ADMIN \
        -e DISPLAY=$DISPLAY \
        -e GITEMAIL="${GITEMAIL}" -e GITNAME="${GITNAME}" \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $HOME/.Xauthority:/home/$DOCKER_USERNAME/.Xauthority \
        -v $HOME:/workspace \
        -v ${HOME}/.ssh/id_rsa:/home/$DOCKER_USERNAME/.ssh/id_rsa:ro \
        marblestation/base

