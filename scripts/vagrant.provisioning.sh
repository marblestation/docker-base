#!/usr/bin/env bash
set -x
set -e

export DEBIAN_FRONTEND=noninteractive
#-------------------------------------------------------------------------------
apt-get update
apt-get upgrade -y -o Dpkg::Options::="--force-confold"
#-------------------------------------------------------------------------------
# Packages needed to add external repository
apt-get install -y --no-install-recommends apt-transport-https ca-certificates
#-------------------------------------------------------------------------------
# Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
usermod -aG docker ubuntu
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
apt-get install -y --no-install-recommends \
    sudo \
    wget \
    ca-certificates \
    apt-transport-https \
    git \
    x11-apps
apt-get install -y --no-install-recommends \
	build-essential \
	gfortran \
	libncurses5-dev \
	libblas-dev \
	liblapack-dev \
	libatlas-base-dev \
	libfreetype6-dev \
	libpng-dev \
	libhdf5-dev \
	htop \
	locales \
	libssl-dev \
	curl \
	bash-completion \
	file \
	git-gui \
	tig \
	exuberant-ctags \
	tmux \
	less \
	rsync \
	sqlite3 \
	openssh-client \
	sshfs \
	net-tools \
	iputils-ping \
	psmisc
sed -i -e "s/#user_allow_other/user_allow_other/g" /etc/fuse.conf
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

## VIM 8.0 #####################################################################
#-------------------------------------------------------------------------------
add-apt-repository -y ppa:jonathonf/vim
apt-get update
apt-get install -y --no-install-recommends vim
#-------------------------------------------------------------------------------
################################################################################


## PYTHON ######################################################################
#-------------------------------------------------------------------------------
apt-get install -y --no-install-recommends \
												python \
												python-dev \
												python-tk \
												python-pip \
												python-numpy \
												python-scipy \
												python-matplotlib \
												python-pandas \
												python-setuptools
pip install --upgrade pip
pip install --upgrade numpy
pip install --upgrade scipy
pip install --upgrade matplotlib
pip install --upgrade pandas
pip install tables
pip install wheel
pip install jupyter
pip install astropy
pip install pudb
pip install cython
pip install pyflakes
pip install scikit-learn
pip install lockfile
pip install patsy
pip install statsmodels
#-------------------------------------------------------------------------------
################################################################################

## Latex #######################################################################
#-------------------------------------------------------------------------------
apt-get install -y --no-install-recommends \
    texlive texlive-bibtex-extra texlive-fonts-extra texlive-latex-extra texlive-publishers \
    latexmk \
    texlive texlive-lang-french texlive-lang-spanish
#-------------------------------------------------------------------------------
################################################################################


## RUST ########################################################################
#-------------------------------------------------------------------------------
curl https://sh.rustup.rs -sSf | su - -c "sh -s -- -y" ubuntu
#-------------------------------------------------------------------------------
################################################################################


## GOLANG ######################################################################
#-------------------------------------------------------------------------------
GOLANG_VERSION=1.9
curl -sLO https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz
tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz
rm -f go${GOLANG_VERSION}.linux-amd64.tar.gz
#-------------------------------------------------------------------------------
################################################################################


## WEB DEVELOPMENT #############################################################
#-------------------------------------------------------------------------------
# NodeJS
apt-get install -y --no-install-recommends nodejs nodejs-legacy npm 
#-------------------------------------------------------------------------------
################################################################################



### FINAL SETUP #################################################################
#-------------------------------------------------------------------------------
# Vim setup for the current user
USER=ubuntu
HOME=/home/${USER}
cd $HOME
mkdir -p ${HOME}/.vim/undodir/
mkdir -p ${HOME}/.vim/spell/
mkdir -p ${HOME}/.vim/autoload/
wget --quiet https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -O ${HOME}/.vim/autoload/plug.vim
wget --quiet https://raw.githubusercontent.com/marblestation/vim-complex-sensible/master/vimrc -O ${HOME}/.vim/vimrc
ln -s ${HOME}/.vim/vimrc ${HOME}/.vimrc
wget --quiet http://ftp.vim.org/vim/runtime/spell/en.utf-8.spl -O ${HOME}/.vim/spell/en.utf-8.spl
wget --quiet http://ftp.vim.org/vim/runtime/spell/en.utf-8.sug -O ${HOME}/.vim/spell/en.utf-8.sug
wget --quiet http://ftp.vim.org/vim/runtime/spell/es.utf-8.spl -O ${HOME}/.vim/spell/es.utf-8.spl
wget --quiet http://ftp.vim.org/vim/runtime/spell/es.utf-8.sug -O ${HOME}/.vim/spell/es.utf-8.sug
wget --quiet http://ftp.vim.org/vim/runtime/spell/fr.utf-8.spl -O ${HOME}/.vim/spell/fr.utf-8.spl
wget --quiet http://ftp.vim.org/vim/runtime/spell/fr.utf-8.sug -O ${HOME}/.vim/spell/fr.utf-8.sug
wget --quiet http://ftp.vim.org/vim/runtime/spell/ca.utf-8.spl -O ${HOME}/.vim/spell/ca.utf-8.spl
wget --quiet http://ftp.vim.org/vim/runtime/spell/ca.utf-8.sug -O ${HOME}/.vim/spell/ca.utf-8.sug
#su - -c "vim +PlugInstall +qall" ${USER}

#wget --quiet https://raw.githubusercontent.com/marblestation/docker-base/master/configurations/bash_profile -O ${HOME}/.bash_profile
#wget --quiet https://raw.githubusercontent.com/marblestation/docker-base/master/configurations/tmux.conf -O ${HOME}/.tmux.conf
cp -f /vagrant/configurations/bash_profile ${HOME}/.bash_profile
sed -i -e "s/GITNAME=\"<edit>\"/GITNAME=\"${GITNAME}\"/g" ${HOME}/.bash_profile
sed -i -e "s/GITEMAIL=\"<edit>\"/GITEMAIL=\"${GITEMAIL}\"/g" ${HOME}/.bash_profile
cp -f /vagrant/configurations/tmux.conf ${HOME}/.tmux.conf
echo "source \$HOME/.bash_profile" >> ${HOME}/.bashrc
git clone https://github.com/magicmonty/bash-git-prompt.git ${HOME}/.bash-git-prompt --depth=1

if [ ! -z "$GITEMAIL" ]; then
    git config --global user.email "$GITEMAIL"
fi
if [ ! -z "$GITNAME" ]; then
    git config --global user.name "$GITNAME"
fi
git config --global push.default simple

chown -R ${USER}:${USER} ${HOME}/.vim/ ${HOME}/.vimrc ${HOME}/.bash_profile ${HOME}/.tmux.conf ${HOME}/.bash-git-prompt ${HOME}/.gitconfig

USER=root
HOME=/root

#-------------------------------------------------------------------------------
# Cleaning
apt-get clean
apt-get autoremove --purge -y
export HISTFILE=/dev/null
rm -rf \
	/root/.bash_history \
	/home/ubuntu/.bash_history \
	/root/.cache/* \
	/tmp/* \
	/var/tmp/*
#rm -rf /var/lib/apt/lists/* 
#-------------------------------------------------------------------------------

