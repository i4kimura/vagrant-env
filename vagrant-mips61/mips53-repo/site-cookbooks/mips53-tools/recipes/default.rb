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

directory "#{gcc_build_dir}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute "build gcc-1" do
  cwd "#{gcc_build_dir}"
  command "../configure --target=#{target} --disable-nls --disable-libssp --with-gnu-ld --with-gnu-as --disable-shared --enable-languages=c && make && make install"
  action :run
end


remote_file "#{Chef::Config[:file_cache_path]}/newlib-2.4.0.tar.gz" do
  source "ftp://sourceware.org/pub/newlib/newlib-2.4.0.tar.gz"
end

execute "extract newlib" do
  cwd Chef::Config[:file_cache_path]
  command "tar xfz ./newlib-2.4.0.tar.gz"
  action :run
end


directory "#{newlib_build_dir}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute "build newlib" do
  cwd "#{newlib_build_dir}"
  command "../configure --target=#{target} --prefix=/usr/local && make && make install"
  action :run
end


execute "build gcc-2" do
  cwd "#{gcc_build_dir}"
  command "rm * -rf && ../configure --target=#{target} --disable-nls --disable-libssp --with-gnu-ld --with-gnu-as --disable-shared --enable-languages=\"c c++\" --with-newlib"
  action :run
end

directory "/home/vagrant/software" do
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  action :create
end

# Install CMake
remote_file "/home/vagrant/software/cmake-3.4.1.tar.gz" do
  source "http://www.cmake.org/files/v3.4/cmake-3.4.1.tar.gz"
end
execute "build-cmake" do
  cwd "/home/vagrant/software/"
  command "tar xfz ./cmake-3.4.1.tar.gz && cd cmake-3.4.1/ && ./configure && make && make install"
  action :run
end


# Install Swimmer-MIPS
git "/home/vagrant/swimmer_iss" do
  repository "https://github.com/msyksphinz/swimmer_iss.git"
  revision "master"
  user "vagrant"
  group "vagrant"
  revision "master"
  action :sync
end

execute "build-swimmer-mips" do
  cwd "/home/vagrant/swimmer_iss"
  command "git submodule init &&
           git submodule update &&
           cd vendor/gflags  # for building Google Flags
           cmake .
           make"
  user "vagrant"
  group "vagrant"
  action :run
end


execute "build-swimmer-mips" do
  cwd "/home/vagrant/swimmer_iss/build_mips"
  command "cmake . && make clean && make"
  user "vagrant"
  group "vagrant"
  action :run
end


# Install U-boot-MIPS
git "/home/vagrant/u-boot-mips" do
  repository "git://git.denx.de/u-boot-mips.git"
  revision "master"
  user "vagrant"
  group "vagrant"
  action :sync
end


# Install XV6-MIPS
git "/home/vagrant/xv6-mips" do
  repository "https://github.com/msyksphinz/xv6-mips.git"
  revision "feature/mipsel-linux-elf"
  user "vagrant"
  group "vagrant"
  action :sync
end
# Install XV6-x86
git "/home/vagrant/xv6-public" do
  repository "https://github.com/mit-pdos/xv6-public.git"
  revision "master"
  user "vagrant"
  group "vagrant"
  action :sync
end


# Install Benchmark
git "/home/vagrant/benchmarks" do
  repository "https://github.com/msyksphinz/benchmarks.git"
  revision "master"
  user "vagrant"
  group "vagrant"
  action :sync
end


# Download MIPS official gcc

remote_file "/home/vagrant/software/Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.MTI.Linux.CentOS-5.x86_64.tar.gz" do
  source "http://codescape-mips-sdk.imgtec.com/components/toolchain/2015.01-7/Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.MTI.Linux.CentOS-5.x86_64.tar.gz"
  user "vagrant"
  group "vagrant"
end

remote_file "/home/vagrant/software/Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.IMG.Linux.CentOS-5.x86_64.tar.gz" do
  source "http://codescape-mips-sdk.imgtec.com/components/toolchain/2015.01-7/Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.IMG.Linux.CentOS-5.x86_64.tar.gz"
  user "vagrant"
  group "vagrant"
end

remote_file "/home/vagrant/software/Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.MTI.Bare.Metal.CentOS-5.x86_64.tar.gz" do
  source "http://codescape-mips-sdk.imgtec.com/components/toolchain/2015.01-7/Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.MTI.Bare.Metal.CentOS-5.x86_64.tar.gz"
  user "vagrant"
  group "vagrant"
end

remote_file "/home/vagrant/software/Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.IMG.Bare.Metal.CentOS-5.x86_64.tar.gz" do
  source "http://codescape-mips-sdk.imgtec.com/components/toolchain/2015.01-7/Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.IMG.Bare.Metal.CentOS-5.x86_64.tar.gz"
  user "vagrant"
  group "vagrant"
end

execute "extract MTI Linux" do
  cwd "/home/vagrant/software"
  command "tar xfz Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.MTI.Linux.CentOS-5.x86_64.tar.gz"
  user "vagrant"
  group "vagrant"
  action :run
end

execute "extract MTI Baremetal" do
  cwd "/home/vagrant/software"
  command "tar xfz Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.MTI.Bare.Metal.CentOS-5.x86_64.tar.gz"
  user "vagrant"
  group "vagrant"
  action :run
end

execute "extract IMG Linux" do
  cwd "/home/vagrant/software"
  command "tar xfz Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.IMG.Linux.CentOS-5.x86_64.tar.gz"
  user "vagrant"
  group "vagrant"
  action :run
end

execute "extract MTI Baremetal" do
  cwd "/home/vagrant/software"
  command "tar xfz Codescape.GNU.Tools.Package.2015.01-7.for.MIPS.IMG.Bare.Metal.CentOS-5.x86_64.tar.gz"
  user "vagrant"
  group "vagrant"
  action :run
end
