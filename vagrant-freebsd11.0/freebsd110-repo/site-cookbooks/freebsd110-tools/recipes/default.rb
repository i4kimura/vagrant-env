#
# Cookbook Name:: FreeBSD10.3-tools
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# packages = %w{bison gmp mpfr mpc git subversion}
#
# packages.each{|package|
#   freebsd_package ${package} do
#     action [:install]
#   end
# }
#
# git "/home/vagrant/riscv-gnu-toolchain" do
#   repository "https://github.com/freebsd-riscv/riscv-gnu-toolchain"
#   revision "master"
#   enable_submodules true
#   action :sync
# end


csh "<<<< BUILD riscv-gnu-toolchain >>>" do
  environment 'TOP'   => "/home/vagrant/"
  environment 'RISCV' => "/home/vagrant/riscv"
  environment 'PREFIX' => "/home/vagrant/riscv"
  environment 'PATH'  => "/home/vagrant/riscv/bin:#{ENV["PATH"]}"

  cwd "/home/vagrant/riscv-gnu-toolchain/"
  command "./configure --prefix=$PREFIX && gmake freebsd"
  action :run
end
