
# Docker container

This container provides a linux environment with a custom setup.

## Build the image

```bash
docker build -t marblestation/base .
```

By default, there will be a user created named 'docker'. But the user name can be changed:

```bash
docker build --build-arg USERNAME=john -t marblestation/base .
```

### Selective cache layers:

* Include the following command in the Dockerfile from the point where layers should be ignored if they are in the cache (i.e., force execution):

```
ARG CACHEBUST=1
```

* Build as:

```bash
docker build -t marblestation/base --build-arg CACHEBUST=$(date +%s) .
```

## Run the image

### Linux / OS X


* (OSX only) Install [XQuartz](https://www.xquartz.org/) [minimum 2.7.11](https://www.xquartz.org/releases/) and open XQuartz: open -a XQuartz
    1. Update preferences 'Security' tab - turn on 'Allow connection from network clients'
    2. Restart XQuartz and then check to see that it is listening on port 6000: lsof -i :6000

* Add to the end of '$HOME/.bashrc':

```bash
# Run container based on the base image, if it already exist start/attach
docker_base_container() {
    GITNAME="Sergi Blanco-Cuaresma"
    GITEMAIL="marblestation@users.noreply.github.com"
    DOCKER_USERNAME="docker"

	PLATFORM=`uname`
	clear

	if [[ "$PLATFORM" == 'Darwin' ]]; then
		DOCKER_IP=$(ifconfig $(route -n get default |grep interface|cut -f 2 -d ':') | grep inet | awk '$1=="inet" {print $2}')
		xhost + $DOCKER_IP
	fi

	STATUS=$(docker inspect --format="{{ .State.Status  }}" base 2>/dev/null )
	if [ $? -eq 0 ]; then
		if [ ${STATUS} = "exited" ]; then
			echo -e "\n>>> Attaching to already existing container, press ENTER if you don't see the linux prompt."
			docker start base > /dev/null # It is needed to have it running for 'exec' to work
		elif [ ${STATUS} = "running" ]; then
			echo -e "\n>>> Attaching to already running container, press ENTER if you don't see the linux prompt."
		fi
		
		if [[ "$PLATFORM" == 'Darwin' ]]; then
			echo -e "\n>>> Run 'source /home/$DOCKER_USERNAME/.display' to update XQuartz/X11 display environment variable."
			docker exec -d base bash -c "echo 'export DISPLAY=$DOCKER_IP:0' > /home/$DOCKER_USERNAME/.display"
		fi
		echo -e "\n>>> Detach with 'ctrl-q,q'.\n"
		docker start -ia --detach-keys="ctrl-q,q" base
	else
		echo -e "\n>>> Detach with ctrl-q,q.\n"

		if [[ "$PLATFORM" == 'Linux' ]]; then
			docker run -it \
					--name base \
					--detach-keys="ctrl-q,q" \
					--device /dev/fuse --cap-add SYS_ADMIN \
					-e DISPLAY=$DISPLAY \
					-e GITEMAIL="${GITEMAIL}" -e GITNAME="${GITNAME}" \
					-v /tmp/.X11-unix:/tmp/.X11-unix \
					-v $HOME:/home/$DOCKER_USERNAME/workspace \
					-v ${HOME}/.ssh/id_rsa:/home/$DOCKER_USERNAME/.ssh/id_rsa:ro \
					marblestation/base
				#-p 127.0.0.1:8888:8888 \
		elif [[ "$PLATFORM" == 'Darwin' ]]; then
			docker run -it \
					--name astro \
					--detach-keys="ctrl-q,q" \
					--device /dev/fuse --cap-add SYS_ADMIN \
					-e DISPLAY=$DOCKER_IP:0 \
					-e GITEMAIL="${GITEMAIL}" -e GITNAME="${GITNAME}" \
					-v $HOME:/home/$DOCKER_USERNAME/workspace \
					-v ${HOME}/.ssh/id_rsa:/home/$DOCKER_USERNAME/.ssh/id_rsa:ro \
					marblestation/astro
				#-p 127.0.0.1:8888:8888 \
		fi
	fi
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
```

* Load the new configuration:

```
source $HOME/.bashrc
```

* Run the image:

```
docker_base_container
```

**NOTE:** If we want to use jupyter notebook, the container should be run with '-p 127.0.0.1:8888:8888' and, once inside, execute: 

```bash
jupyter notebook --ip=*
```

## Docker Hub

### Pull the image

```bash
docker pull marblestation/base:latest
```
