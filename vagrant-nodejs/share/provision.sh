#!/bin/bash

if ! [ `which ansible` ]; then
    yum install -y update
    yum install -y install python-devel python-pip
    pip install ansible
fi

home=/home/$1
node_version=$2

# install nvm
git clone https://github.com/creationix/nvm.git $home/.nvm

# install node
source $home/.nvm/nvm.sh
nvm install $node_version

# ログインシェルに登録

cat << _EOT_ >> $home/.bashrc
source ~/.nvm/nvm.sh
nvm use $node_version > /dev/null
_EOT_


sudo sed -i 's/Defaults    env_reset/Defaults    !env_reset/g' /etc/sudoers
sudo sed -i 's/# Defaults    env_keep/Defaults    env_keep/g' /etc/sudoers
sudo sed -i 's/Defaults    secure_path/# Defaults    secure_path/g' /etc/sudoers

npm install request
