# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # VM 0
  config.vm.define :base do |base|
    # Define box
    base.vm.box = "ubuntu/xenial64"
    base.vm.hostname = "vagrant-base"
    #base.vm.network :private_network, ip: "10.10.10.10"
    base.vm.network "forwarded_port", guest: 8888, host: 18888, auto_correct: true # Jupyter
	base.vm.synced_folder ENV['HOME'], "/home/ubuntu/workspace" # Apart from /vagrant
    base.vm.provider "virtualbox" do |vb|
        #vb.memory = "2048"
        vb.memory = "4096"
        #vb.memory = "8192"
        vb.cpus = 1
    end
    # SSH
    base.ssh.forward_agent = true
    base.ssh.forward_x11 = true
    # Provision
    base.vm.provision :shell, :path => "./scripts/vagrant.provisioning.sh", 
		env: {
				"GITNAME" => ENV['GITNAME'],
				"GITEMAIL" => ENV['GITEMAIL'],
			}
  end

end
