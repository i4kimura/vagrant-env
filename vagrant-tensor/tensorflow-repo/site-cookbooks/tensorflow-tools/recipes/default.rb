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
              graphviz gawk gtkterm silversearcher-ag zip unzip zlib1g-dev
              liblua5.2-dev libbfd-dev binutils-dev openjdk-8-jdk}
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

git "/home/vagrant/bazel" do
  repository "https://github.com/bazelbuild/bazel.git"
  revision "0.1.1"
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