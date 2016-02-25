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

packages = %w{g++ bison flex libmpc-dev  libmpfr-dev libgmp-dev texinfo libexpat1-dev
              libncurses5-dev cmake libxml2-dev python-dev swig doxygen subversion
              libedit-dev git libtool automake libhidapi-dev libusb-1.0-0-dev
              graphviz gawk gtkterm silversearcher-ag zip unzip zlib1g-dev python-pip
              liblua5.2-dev binutils-dev libffi-dev libssl-dev
              libblas3 liblapack3
              build-essential curl libfreetype6-dev libpng12-dev libzmq3-dev
              python-pyasn1 python-pyasn1-modules swig python-dev
              pkg-config software-properties-common}
packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end


dist = node['lsb']['codename']
execute "add ppa:webupdate8team" do
  command "add-apt-repository ppa:webupd8team/java"
  creates "/etc/apt/sources.list.d/webupd8team-#{dist}.list"
end

execute "apt-get update"
execute "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections"
execute "echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections"
execute "DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer"

# Download source code of TensorFlow
git "/home/vagrant/tensorflow" do
  repository "https://github.com/tensorflow/tensorflow"
  revision "master"
  enable_submodules true
  user "vagrant"
  group "vagrant"
  action :sync
end

git "/home/vagrant/bazel" do
  repository "https://github.com/bazelbuild/bazel.git"
  revision "0.1.1"
  enable_submodules true
  user "vagrant"
  group "vagrant"
  action :sync
end


execute "extract pip_python" do
  cwd "/home/vagrant/"
  command "pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.5.0-cp27-none-linux_x86_64.whl"
  action :run
end


directory '/home/vagrant/download' do
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  action :create
end


remote_file "/home/vagrant/download/python-numpy_1.10.4-2ubuntu2_amd64.deb" do
  source "https://launchpad.net/ubuntu/+archive/primary/+files/python-numpy_1.10.4-2ubuntu2_amd64.deb"
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  action :create
end


execute "install numpy-1.10.4" do
  cwd "/home/vagrant/download/"
  command "dpkg -i ./python-numpy_1.10.4-2ubuntu2_amd64.deb"
end


remote_file "/home/vagrant/download/bazel-0.1.5-installer-linux-x86_64.sh" do
  source "https://github.com/bazelbuild/bazel/releases/download/0.1.5/bazel-0.1.5-installer-linux-x86_64.sh"
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  action :create
end


file "/home/vagrant/download/bazel-0.1.5-installer-linux-x86_64.sh" do
  mode '0755'
end

execute "install bazel" do
  user "vagrant"
  environment "HOME" => "/home/vagrant"
  cwd "/home/vagrant/download/"
  command "./bazel-0.1.5-installer-linux-x86_64.sh --user --prefix=/home/vagrant/ --bin=/home/vagrant/bin --base=/home/vagrant/.bazel --bazelrc=/home/vagrant/.bazelrc"
end

execute "extract python_pip grpcio" do
  command "sudo pip install --upgrade ndg-httpsclient && pip install grpcio"
end

git "/home/vagrant/serving" do
  repository "https://github.com/tensorflow/serving"
  enable_submodules true
  user "vagrant"
  group "vagrant"
  action :sync
end


execute "configure tensorflow serving" do
  cwd "/home/vagrant/serving/tensorflow/"
  command "./configure"
  user "vagrant"
  group "vagrant"
end

execute "install tensorflow servivg" do
  cwd "/home/vagrant/serving/"
  environment "HOME" => "/home/vagrant"
  command "/home/vagrant/bin/bazel build tensorflow_serving/..."
  user "vagrant"
  group "vagrant"
end
