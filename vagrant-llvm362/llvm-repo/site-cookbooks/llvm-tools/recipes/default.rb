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

packages = %w{g++ bison flex libmpc-dev  libmpfr-dev libgmp-dev texinfo libexpat1-dev libncurses5-dev cmake libxml2-dev python-dev swig doxygen subversion libedit-dev git libtool automake libhidapi-dev libusb-1.0-0-dev graphviz gawk gtkterm emacs}
packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end


target="mipsel-linux-elf"

binutils_build_dir = "#{Chef::Config['file_cache_path']}/binutils-2.25/build/"
gcc_build_dir = "#{Chef::Config[:file_cache_path]}/gcc-5.1.0/build/"
newlib_build_dir = "#{Chef::Config[:file_cache_path]}/newlib-2.2.0.20150423/build/"

llvm_ver="3.6.2"
llvm_url="http://llvm.org/releases/#{llvm_ver}"

remote_file "#{Chef::Config[:file_cache_path]}/llvm-#{llvm_ver}.src.tar.xz" do
  # source #{llvm_url}/llvm-#{llvm_ver}.src.tar.xz
  source "http://llvm.org/releases/#{llvm_ver}/llvm-#{llvm_ver}.src.tar.xz"
end

remote_file "#{Chef::Config[:file_cache_path]}/cfe-#{llvm_ver}.src.tar.xz" do
  source "http://llvm.org/releases/#{llvm_ver}/cfe-#{llvm_ver}.src.tar.xz"
end

remote_file "#{Chef::Config[:file_cache_path]}/lldb-#{llvm_ver}.src.tar.xz" do
  source "http://llvm.org/releases/#{llvm_ver}/lldb-#{llvm_ver}.src.tar.xz
end

remote_file "#{Chef::Config[:file_cache_path]}/lld-#{llvm_ver}.src.tar.xz" do
  source "http://llvm.org/releases/#{llvm_ver}/lld-#{llvm_ver}.src.tar.xz"
end

remote_file "#{Chef::Config[:file_cache_path]}/test-suite-#{llvm_ver}.src.tar.xz" do
  source "http://llvm.org/releases/#{llvm_ver}/test-suite-#{llvm_ver}.src.tar.xz"
end

remote_file "#{Chef::Config[:file_cache_path]}/compiler-rt-#{llvm_ver}.src.tar.xz" do
  source "http://llvm.org/releases/#{llvm_ver}/compiler-rt-#{llvm_ver}.src.tar.xz"
end

remote_file "#{Chef::Config[:file_cache_path]}/libcxx-#{llvm_ver}.src.tar.xz" do
  source "http://llvm.org/releases/#{llvm_ver}/libcxx-#{llvm_ver}.src.tar.xz"
end


# execute "extract binutils" do
#   cwd Chef::Config[:file_cache_path]
#   command "tar xfz ./binutils-2.25.tar.gz"
#   action :run
# end
#
# directory "#{binutils_build_dir}" do
#   owner 'root'
#   group 'root'
#   mode '0755'
#   action :create
# end
#
# cookbook_file "#{Chef::Config['file_cache_path']}/binutils-2.25/ld/ldmain.patch" do
#   source "ldmain.patch"
# end
#
#
# execute "apply ldmain patch" do
#   cwd "#{Chef::Config['file_cache_path']}/binutils-2.25/ld/"
#   command "patch --ignore-whitespace < ldmain.patch"
# end
#
#
# execute "build binutils" do
#   cwd "#{binutils_build_dir}"
#   command "../configure --target=#{target} --disable-nls --enable-gold && make && sudo make install"
#   action :run
# end
#
#
# remote_file "#{Chef::Config[:file_cache_path]}/gcc-5.1.0.tar.gz" do
#   source "http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-5.1.0/gcc-5.1.0.tar.gz"
# end
#
# execute "extract gcc" do
#   cwd Chef::Config[:file_cache_path]
#   command "tar xfz ./gcc-5.1.0.tar.gz"
#   action :run
# end
#
# directory "#{gcc_build_dir}" do
#   owner 'root'
#   group 'root'
#   mode '0755'
#   action :create
# end
#
# execute "build gcc-1" do
#   cwd "#{gcc_build_dir}"
#   command "../configure --target=#{target} --disable-nls --disable-libssp --with-gnu-ld --with-gnu-as --with-gc=boehm --disable-shared --enable-languages=c && make && make install"
#   action :run
# end
#
#
# remote_file "#{Chef::Config[:file_cache_path]}/newlib-2.2.0.20150423.tar.gz" do
#   source "ftp://sourceware.org/pub/newlib/newlib-2.2.0.20150423.tar.gz"
# end
#
# execute "extract newlib" do
#   cwd Chef::Config[:file_cache_path]
#   command "tar xfz ./newlib-2.2.0.20150423.tar.gz"
#   action :run
# end
#
#
# directory "#{newlib_build_dir}" do
#   owner 'root'
#   group 'root'
#   mode '0755'
#   action :create
# end
#
# execute "build newlib" do
#   cwd "#{newlib_build_dir}"
#   command "../configure --target=#{target} --prefix=/usr/local && make && make install"
#   action :run
# end
#
#
# execute "build gcc-2" do
#   cwd "#{gcc_build_dir}"
#   command "rm * -rf && ../configure --target=#{target} --disable-nls --disable-libssp --with-gnu-ld --with-gnu-as --with-gc=boehm --disable-shared --enable-languages=\"c c++\" --with-newlib"
#   action :run
# end
#
#
# packages = %w{emacs}
# packages.each do |pkg|
#   package pkg do
#     action [:install, :upgrade]
#   end
# end
