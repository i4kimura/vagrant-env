#
# Cookbook Name:: mips53-tools
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
  command "sed -i -e 's%http://archive.ubuntu.com/ubuntu%http://jp.archive.ubuntu.com/ubuntu%g' /etc/apt/sources.list"
end.run_action(:run)

packages = %w{g++ bison flex libmpc-dev  libmpfr-dev libgmp-dev texinfo libexpat1-dev
              libncurses5-dev cmake libxml2-dev python-dev swig doxygen subversion
              libedit-dev git libtool automake libhidapi-dev libusb-1.0-0-dev
              graphviz gawk gtkterm silversearcher-ag
              liblua5.2-dev libbfd-dev binutils-dev
              emacs lua-mode}
packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end


target="mipsel-linux-elf"
# target="x86_64-linux-gnu"

binutils_build_dir = "#{Chef::Config['file_cache_path']}/binutils-2.26/build/"
gcc_dir       = "#{Chef::Config[:file_cache_path]}/gcc-6.1.0/"
gcc_build_dir = "#{Chef::Config[:file_cache_path]}/gcc-6.1.0/build/"
newlib_build_dir = "#{Chef::Config[:file_cache_path]}/newlib-2.4.0/build/"


remote_file "#{Chef::Config[:file_cache_path]}/binutils-2.26.tar.gz" do
  source "http://ftp.gnu.org/gnu/binutils/binutils-2.26.tar.gz"
end


execute "extract binutils" do
  cwd Chef::Config[:file_cache_path]
  command "tar xfz ./binutils-2.26.tar.gz"
  action :run
end

directory "#{binutils_build_dir}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute "build binutils" do
  cwd "#{binutils_build_dir}"
  command "../configure --target=#{target} --disable-nls --enable-gold && make && sudo make install"
  action :run
end


remote_file "#{Chef::Config[:file_cache_path]}/gcc-6.1.0.tar.gz" do
  source "http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-6.1.0/gcc-6.1.0.tar.gz"
end

execute "extract gcc" do
  cwd Chef::Config[:file_cache_path]
  command "tar xfz ./gcc-6.1.0.tar.gz"
  action :run
end


execute "download depends package" do
  cwd "#{gcc_dir}"
  command "./contrib/download_prerequisites"
  action :run
end


directory "#{gcc_build_dir}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute "configure gcc" do
  cwd "#{gcc_build_dir}"
  command "../configure --enable-languages=c,c++ --prefix=/usr/local --disable-bootstrap --disable-multilib"
  action :run
end


execute "make gcc" do
  action :run
  cwd "#{gcc_build_dir}"
  command "make && make install"
end
