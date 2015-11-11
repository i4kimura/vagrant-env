#
# Cookbook Name:: mips51-tools
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "update package index" do
  command "apt-get update"
  ignore_failure true
end.run_action(:run)

execute "sed apt-source" do
  command "sed -i -e 's%http://archive.ubuntu.com/ubuntu%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive%g' /etc/apt/sources.list"
end.run_action(:run)

packages = %w{g++ bison flex libncurses5-dev cmake swig
              git libtool automake silversearcher-ag emacs
              python-pip}
packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

# Download source code of TensorFlow
git "/home/vagrant/tensorflow" do
  repository "https://github.com/tensorflow/tensorflow"
  revision "master"
  enable_submodules true
  user "vagrant"
  group "vagrant"
  action :sync
end

packages = %w{python-numpy swig python-dev}
packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end


execute "extract pip_python" do
  cwd "/home/vagrant/"
  command "pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.5.0-cp27-none-linux_x86_64.whl"
  action :run
end
