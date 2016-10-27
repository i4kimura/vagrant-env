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

packages = %w{autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf gcc libc6-dev pkg-config bridge-utils uml-utilities zlib1g-dev libglib2.0-dev autoconf automake libtool libsdl1.2-dev emacs git default-jre default-jdk lib32z1 lib32ncurses5 lib32stdc++6 libssl-dev device-tree-compiler bc}

packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

git "/home/vagrant/u-boot-xlnx" do
  repository "https://github.com/Xilinx/u-boot-xlnx.git"
  revision "xilinx-v#{node['vivado']['version']}"
  enable_submodules true
  action :sync
  user "vagrant"
  group "vagrant"
end

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


execute "Installing Vivado (1)" do
  command "tar xfz /vagrant/shared/#{node['vivado']['file_head']}_#{node['vivado']['version']}_#{node['vivado']['date']}_1.tar.gz -C /home/vagrant/"
  action :run
  user "vagrant"
  group "vagrant"
end

execute "Installing Vivado (2)" do
  cwd "/home/vagrant/#{node['vivado']['file_head']}_#{node['vivado']['version']}_#{node['vivado']['date']}_1"
  command "./xsetup --agree XilinxEULA,3rdPartyEULA,WebTalkTerms --batch Install --config /vagrant/shared/install_config.txt"
  action :run
end


execute "Creating .Xilinx" do
  cwd "/home/vagrant/"
  command "mkdir -p .Xilinx"
  user  "vagrant"
  group "vagrant"
  action :run
end


remote_file "/home/vagrant/.Xilinx/Xilinx.lic" do
  source "file:///vagrant/shared/Xilinx.lic"
  owner "vagrant"
  group "vagrant"
  mode 0755
end


directory "/home/vagrant/#{node['vivado']['file_head']}_#{node['vivado']['version']}_#{node['vivado']['date']}_1" do
  action :delete
  recursive true
end


bash "make zedboard" do
  cwd "/home/vagrant/u-boot-xlnx/"
  code <<-EOS
       source /opt/Xilinx/SDK/#{node['vivado']['version']}/settings64.sh
       export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
       unset LD_LIBRARY_PATH
       make zynq_zed_config
       make
   EOS
  action :run
  user  "vagrant"
  group "vagrant"
end

#       source /opt/Xilinx/SDK/#{node['vivado']['version']}/settings64.sh

git "/home/vagrant/hdl" do
  repository "https://github.com/analogdevicesinc/hdl.git"
  revision "hdl_2015_r2"
  enable_submodules true
  action :sync
  user "vagrant"
  group "vagrant"
end


execute "Sed IP version (1)" do
  cwd "/home/vagrant/hdl/"
  command "sed -i 's/#{node['vivado']['version']}.1/#{node['vivado']['version']}/g' library/scripts/adi_ip.tcl"
  action :run
  user  "vagrant"
  group "vagrant"
end


execute "Sed IP version (2)" do
  cwd "/home/vagrant/hdl/"
  command "sed -i 's/#{node['vivado']['version']}.1/#{node['vivado']['version']}/g' projects/scripts/adi_project.tcl"
  action :run
  user  "vagrant"
  group "vagrant"
end


execute "make project" do
  cwd "/home/vagrant/hdl/projects/adv7511/zed"
  command "source /opt/Xilinx/Vivado/#{node['vivado']['version']}/settings64.sh && make"
  action :run
  user  "vagrant"
  group "vagrant"
end
