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

packages = %w{autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf gcc libc6-dev pkg-config bridge-utils uml-utilities zlib1g-dev libglib2.0-dev autoconf automake libtool libsdl1.2-dev emacs git default-jre default-jdk}

packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

git "/home/vagrant/rocket-chip" do
  repository "https://github.com/ucb-bar/rocket-chip.git"
  revision "boom"
  enable_submodules true
  action :sync
  user "vagrant"
  group "vagrant"
end

execute "Set Environment of RISCV-tools" do
  cwd "/home/vagrant/rocket-chip/riscv-tools/"
  command "git submodule update --init --recursive"
  action :run
  user "vagrant"
  group "vagrant"
end

ENV['TOP']   = "/home/vagrant/"
ENV['RISCV'] = "/home/vagrant/riscv"
ENV['PATH']  = "/home/vagrant/riscv/bin:#{ENV["PATH"]}"

execute "Build RISCV-tools" do
  cwd "/home/vagrant/rocket-chip/riscv-tools/"
  command "./build.sh"
  action :run
  user "vagrant"
  group "vagrant"
end

#
# Building BOOM
#
execute "Build RISCV-tools" do
  cwd "/home/vagrant/rocket-chip/emulator/"
  command "make run CONFIG=BOOMConfig"
  action :run
  user "vagrant"
  group "vagrant"
end
