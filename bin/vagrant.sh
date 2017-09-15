#!/bin/bash

# Edit:
GITNAME="John Smith" 
GITEMAIL="jsmith@users.noreply.github.com"

echo -e "\n>>> Destroying virtual machine."
vagrant destroy -f base
echo -e "\n>>> Creating virtual machine."
vagrant up base
echo -e "\n>>> SSH into the virtual machine."
vagrant ssh base
