#
# Cookbook Name:: riscv-tools
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "sed apt-source" do
  command "sed -i -e 's%http://archive.ubuntu.com/ubuntu%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive%g' /etc/apt/sources.list"
end.run_action(:run)

execute "update package index" do
  command "apt-get update"
  ignore_failure true
  action :nothing
end.run_action(:run)

packages = %w{gawk wget git-core diffstat unzip texinfo build-essential libsdl1.2-dev emacs}

packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

git "/home/vagrant/" do
  repository "git://git.yoctoproject.org/poky"
  revision "master"
  enable_submodules true
  action :sync
end

git "/home/vagrant/poky" do
  repository "git://git.openembedded.org/meta-openembedded"
  revision "master"
  enable_submodules true
  action :sync
end


git "/home/vagrant/poky" do
  repository "git://git.linaro.org/openembedded/meta-linaro"
  revision "master"
  enable_submodules true
  action :sync
end


git "/home/vagrant/poky" do
  repository "git://git.yoctoproject.org/meta-xilinx"
  revision "master"
  enable_submodules true
  action :sync
end
