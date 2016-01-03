#!/usr/bin/env bash

if ! [ `which ansible` ]; then
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install python-dev python-pip
    pip install ansible
fi

chmod -x /vagrant/ansible/hosts
ansible-playbook -i /vagrant/ansible/hosts /vagrant/ansible/playbook.yml
