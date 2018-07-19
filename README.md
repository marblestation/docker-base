
# Docker container

**NOTE** It requires [Docker](https://store.docker.com/search?type=edition&offering=community).

Docker is a software technology providing an additional layer of abstraction and automation of operating-system-level virtualization on Linux. The container provided in this repository builds a linux environment with a custom setup (same as the one defined in the Vagrantfile).

## Build the image

```bash
docker build -t marblestation/base .
```

There will be a user created named 'docker'. 


## Run the image

### Linux / OS X


* (OSX only) Install [XQuartz](https://www.xquartz.org/) [minimum 2.7.11](https://www.xquartz.org/releases/) and open XQuartz: open -a XQuartz
    1. Update preferences 'Security' tab - turn on 'Allow connection from network clients'
    2. Restart XQuartz and then check to see that it is listening on port 6000: lsof -i :6000

* Add to the end of '$HOME/.bashrc' and change GITNAME and GITEMAIL variables:

```bash
DOCKER_EXEC=$(which docker)
if [ -x "$DOCKER_EXEC" ] ; then
    docker_base_container() {
        GITNAME="<edit>" # Example: John Smith
        GITEMAIL="<edit>" # Example: jsmith@users.noreply.github.com
        DOCKER_USERNAME="docker"

        PLATFORM=`uname`
        if [[ "$PLATFORM" == 'Linux' ]] || [[ "$PLATFORM" == 'Darwin'  ]]; then
            if [[ "$PLATFORM" == 'Darwin' ]]; then
                DOCKER_IP=$(ifconfig $(route -n get default |grep interface|cut -f 2 -d ':') | grep inet | awk '$1=="inet" {print $2}')
                xhost + $DOCKER_IP
            fi

            STATUS=$(docker inspect --format="{{ .State.Status  }}" base 2>/dev/null )
            if [ $? -eq 0 ]; then
                if [[ ${STATUS} = "exited" ]]; then
                    echo -e "\n>>> Starting stopped container."
                    docker start base > /dev/null # It is needed to have it running for 'exec' to work
                elif [[ ${STATUS} = "running" ]]; then
                    echo -e "\n>>> Container already running."
                fi
                
                echo -e "\n>>> Entering into the container, press ENTER if you don't see the linux prompt."
                if [[ "$PLATFORM" == 'Darwin' ]]; then
                    echo -e "\n>>> Run 'source /home/$DOCKER_USERNAME/.display' to update XQuartz/X11 display environment variable."
                    docker exec -d -u $DOCKER_USERNAME base bash -c "echo 'export DISPLAY=$DOCKER_IP:0' > /home/$DOCKER_USERNAME/.display"
                fi
            else
                echo -e "\n>>> Creating container."

                if [[ "$PLATFORM" == 'Darwin' ]]; then
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
                if [[ "$PLATFORM" == 'Linux' ]]; then
                    # Changing ownership by usermod/chown can be extremely slow in some setups in OSX
                    # and in any case, it does not seem to be needed
                    LOCAL_UID=$(id -u)
                    LOCAL_GID=$(id -g)
                    docker exec base usermod -o -u $LOCAL_UID docker
                    docker exec base groupmod -o -g $LOCAL_GID docker
                    docker exec base chown -R $LOCAL_UID:$LOCAL_GID /home/docker
                fi
                docker exec -u docker base ln -s /workspace /home/$DOCKER_USERNAME/workspace
            fi
            echo -e "\n>>> Detach with 'ctrl-q,q'.\n"
            docker exec -it --detach-keys="ctrl-q,q" -u $DOCKER_USERNAME -e COLUMNS=`tput cols` -e LINES=`tput lines` base /bin/bash
        else
            echo -e "\n>>> Unknown/untested platform."
        fi
    }
    
    docker_base_container_restart() {
        PLATFORM=`uname`
        if [[ "$PLATFORM" == 'Linux' ]] || [[ "$PLATFORM" == 'Darwin'  ]]; then
            STATUS=$(docker inspect --format="{{ .State.Status  }}" base 2>/dev/null )
            if [ $? -eq 0 ]; then
                if [[ ${STATUS} = "exited" ]]; then
                    echo -e "\n>>> Removing stopped container."
                    docker rm base
                elif [[ ${STATUS} = "running" ]]; then
                    echo -e "\n>>> Stopping running containter."
                    docker stop base > /dev/null
                    echo -e "\n>>> Removing stopped container."
                    docker rm base > /dev/null
                fi
            fi
        fi
        docker_base_container
    }

    # Kill all running containers.
    alias docker_killall='printf "\n>>> Killing all containers\n\n" && docker kill $(docker ps -q) 2>/dev/null'

    # Stop all running containers.
    alias docker_stopall='printf "\n>>> Stoping all containers\n\n" && docker stop $(docker ps -q) 2>/dev/null'

    # List all containers and images.
    alias docker_listall='printf "\n>>> List all containers\n\n" && docker ps -a && printf "\n>>> List all containers\n\n" && docker images'

    # Delete all stopped containers.
    alias docker_clean_containers='printf "\n>>> Deleting stopped containers\n\n" && docker rm -v $(docker ps -a -q -f status=exited) 2>/dev/null'

    # Delete all untagged images.
    alias docker_clean_images='printf "\n>>> Deleting untagged images\n\n" && docker rmi $(docker images -q -f dangling=true) 2>/dev/null'

    # Delete all stopped containers and untagged images.
    alias docker_clean='docker_clean_containers || true && docker_clean_images'
fi
```

* Load the new configuration:

```
source $HOME/.bashrc
```

* Run the image:

```
docker_base_container
```

**NOTE:** If we want to use jupyter notebook, the container should be run with '-p 127.0.0.1:8888:8888' in OSX or '--net=host' in Linux and, once inside, execute: 

```bash
jupyter notebook --ip=* --no-browser
```

## Docker Hub

### Pull the image

```bash
docker pull marblestation/base:latest
```

# Vagrant virtual machine

**NOTE** It requires [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/). 

Vagrant is a tool for building and maintaining portable virtual software development environments, the Vagrantfile included in this repository creates a virtual machine using VirtualBox with a linux environment with a custom setup (same as the one defined in the Dockerfile). 

To create the virtual machine and ssh into it (all commands should be executed from the directory that contains the Vagrantfile):

```bash
GITNAME="John Smith" 
GITEMAIL="jsmith@users.noreply.github.com"
vagrant up base
```

```bash
vagrant ssh base
```

To suspend, resume, restart, stop and destroy virtual machine:

```bash
vagrant suspend base
vagrant resume base
vagrant reload base
vagrant halt base
vagrant destroy base
```

Finally, to check its status:

```bash
vagrant status
vagrant global-status
```

From within the virtual machine you can access your host user home directory in $HOME/workspace, but you can also mount it via SSHFS (if the host has an active SSH service). For instance:

```bash
VHOST_USER=username
VHOST_IP=$(route | awk '/default/ { print $2   }')
mkdir -p $HOME/remote/vhost
sshfs -o allow_root,uid=1000,gid=1000 ${VHOST_USER}@${VHOST_IP}:/Users/${VHOST_USER} $HOME/remote/vhost
```

```bash
fusermount -u $HOME/remote/vhost
```
