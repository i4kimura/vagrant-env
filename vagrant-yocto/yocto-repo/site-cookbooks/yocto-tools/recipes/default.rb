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

packages = %w{gawk wget git-core diffstat unzip texinfo build-essential chrpath libsdl1.2-dev emacs}

packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

git "/home/vagrant/poky" do
  user "vagrant"
  repository "git://git.yoctoproject.org/poky"
  revision "master"
  enable_submodules true
  action :sync
end

git "/home/vagrant/poky/meta-openembedded" do
  user "vagrant"
  repository "git://git.openembedded.org/meta-openembedded"
  revision "master"
  enable_submodules true
  action :sync
end


git "/home/vagrant/poky/meta-linaro" do
  user "vagrant"
  repository "git://git.linaro.org/openembedded/meta-linaro"
  revision "master"
  enable_submodules true
  action :sync
end


git "/home/vagrant/poky/meta-xilinx" do
  user "vagrant"
  repository "git://git.yoctoproject.org/meta-xilinx"
  revision "master"
  enable_submodules true
  action :sync
end


# bash "Format Build environment" do
#   user "vagrant"
#   cwd "/home/vagrant/poky/"
#   code "source ./oe-init-build-env &&
#         cd /home/vagrant/poky/build/conf/ &&
#         sed -i 's$/home/vagrant/poky/meta-yocto-bsp$/home/vagrant/poky/meta-yocto-bsp \
#                   /home/vagrant/poky/meta-linaro/meta-linaro \
#                   /home/vagrant/poky/meta-openembedded/toolchain-layer \
#                   /home/vagrant/poky/meta-xilinx $g' bblayers.conf &&
#         cd /home/vagrant/poky/build/conf/ &&
#         sed -i 's/#BB_NUMBER_THREADS/BB_NUMBER_THREADS/g' local.conf &&
#         sed -i 's/#PARALLEL_MAKE/PARALLEL_MAKE/g' local.conf &&
#         sed -i 's/MACHINE ??= \"qemux86\"/MACHINE ?= \"zedboard-zynq7\"/g' local.conf &&
#         sed -i 's/debug-tweaks/debug-tweaks tools-sdk/g' local.conf &&
#         cd /home/vagrant/poky/meta-linaro/meta-linaro/conf/ &&
#         sed -i 's/LAYERDEPENDS_linaro/#LAYERDEPENDS_linaro/g' layer.conf &&
#         echo 'LAYERDEPENDS_linaro-toolchain = \"meta-networking\"' >> layer.conf &&
#         cd /home/vagrant/poky/build/ &&
#         bitbake core-image-minimal"
#   action :run
# end


bash "Format Build environment" do
  user "vagrant"
  code "cd /home/vagrant/poky/ &&
        source ./oe-init-build-env &&
        cd /home/vagrant/poky/build/ &&
        bitbake core-image-minimal"
  action :run
end
