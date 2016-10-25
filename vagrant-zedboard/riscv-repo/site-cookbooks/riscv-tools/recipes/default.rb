#
# Cookbook Name:: riscv-tools
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

ENV['TOP']   = "/home/vagrant/"
ENV['RISCV'] = "/home/vagrant/riscv"
ENV['PATH']  = "/home/vagrant/riscv/bin:#{ENV["PATH"]}"
ENV['CROSS_COMPILE'] = "arm-xilinx-linux-gnueabi-"

execute "sed apt-source" do
  command "sed -i -e 's%http://archive.ubuntu.com/ubuntu%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive%g' /etc/apt/sources.list"
end.run_action(:run)

execute "update package index" do
  command "apt-get update"
  ignore_failure true
  action :nothing
end.run_action(:run)

packages = %w{autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf gcc libc6-dev pkg-config bridge-utils uml-utilities zlib1g-dev libglib2.0-dev autoconf automake libtool libsdl1.2-dev emacs git default-jre default-jdk lib32z1 lib32ncurses5 lib32stdc++6 libssl-dev device-tree-compiler}

packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

git "/home/vagrant/u-boot-xlnx" do
  repository "https://github.com/Xilinx/u-boot-xlnx.git"
  revision "xilinx-v2016.2"
  enable_submodules true
  action :sync
  user "vagrant"
  group "vagrant"
end

# execute "remove include/configs/zynq_zed.h" do
#   cwd "/home/vagrant/u-boot-xlnx/"
#   command "rm -rf include/configs/zynq_zed.h"
#   action :run
#   user "vagrant"
#   group "vagrant"
# end

execute "copy include/configs/zynq-common.h" do
  cwd "/home/vagrant/u-boot-xlnx/"
  command "gawk 'BEGIN{start=0; } /#define CONFIG_EXTRA_ENV_SETTINGS/ {start=1;} /DFU_ALT_INFO/ {if(start==1){start=0; print $0;}} /.*/ {if(start==1){print $0;}}'  include/configs/zynq-common.h >> include/configs/zynq_zed.h"
  action :run
  user "vagrant"
  group "vagrant"
end

execute "replace 1" do
  cwd "/home/vagrant/u-boot-xlnx/"
  command "sed -i 's$\"echo Copying Linux from SD to RAM... \" \$\"echo Copying Linux from SD to RAM... RFS in ext4 \"$g' include/configs/zynq_zed.h"
  action :run
  user "vagrant"
  group "vagrant"
end

execute "replace 2" do
  cwd "/home/vagrant/u-boot-xlnx/"
  command "sed -i '/\"load mmc 0 ${ramdisk_load_address} ${ramdisk_image} && \"/d' include/configs/zynq_zed.h"
  action :run
  user "vagrant"
  group "vagrant"
end


execute "replace 3" do
  cwd "/home/vagrant/u-boot-xlnx/"
  command "sed -i 's/\"bootm ${kernel_load_address} ${ramdisk_load_address} ${devicetree_load_address}; \"/\"bootm ${kernel_load_address} - ${devicetree_load_address}; \"/g' include/configs/zynq_zed.h"
  action :run
  user "vagrant"
  group "vagrant"
end

execute "replace 3" do
  cwd "/home/vagrant/u-boot-xlnx/"
  command "sed -i 's/#define CONFIG_EXTRA_ENV_SETTINGS/#ifdef CONFIG_EXTRA_ENV_SETTINGS\\n#undef CONFIG_EXTRA_ENV_SETTINGS\\n#endif\\n#define CONFIG_EXTRA_ENV_SETTINGS/g' include/configs/zynq_zed.h"
  action :run
  user "vagrant"
  group "vagrant"
end


bash "make zedboard" do
  cwd "/home/vagrant/u-boot-xlnx/"
  code <<-EOS
       source /opt/Xilinx/SDK/2016.2/settings64.sh
       export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
       unset LD_LIBRARY_PATH
       make zynq_zed_config
       make
   EOS
  action :run
  user "vagrant"
  group "vagrant"
end
