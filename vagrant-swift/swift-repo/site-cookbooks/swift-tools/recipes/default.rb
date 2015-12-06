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
  command "sed -i -e 's%http://archive.ubuntu.com/ubuntu%http://jp.archive.ubuntu.com/ubuntu%g' /etc/apt/sources.list"
end.run_action(:run)

packages = %w{git cmake ninja-build clang uuid-dev libicu-dev icu-devtools
              libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig
              libpython-dev libncurses5-dev pkg-config
              g++ bison flex libncurses5-dev cmake swig
              git libtool automake silversearcher-ag emacs
              python-pip clang-3.6}

packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

execute "extract clang3.6" do
  cwd "/home/vagrant/"
  command "update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.6 100"
  action :run
end


execute "extract clang3.6++" do
  cwd "/home/vagrant/"
  command "update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100"
  action :run
end

directory "/home/vagrant/swift/" do
  owner "vagrant"
  group "vagrant"
  mode '0755'
  action :create
end

# Download source code of Swift
git "/home/vagrant/swift/swift" do
  repository "https://github.com/apple/swift.git"
  user "vagrant"
  group "vagrant"
  action :sync
end
git "/home/vagrant/swift/llvm" do
  repository "https://github.com/apple/swift-llvm.git"
  user "vagrant"
  group "vagrant"
  action :sync
end
git "/home/vagrant/swift/clang" do
  repository "https://github.com/apple/swift-clang.git"
  user "vagrant"
  group "vagrant"
  action :sync
end
git "/home/vagrant/swift/lldb" do
  repository "https://github.com/apple/swift-lldb.git"
  user "vagrant"
  group "vagrant"
  action :sync
end
git "/home/vagrant/swift/cmark" do
  repository "https://github.com/apple/swift-cmark.git"
  user "vagrant"
  group "vagrant"
  action :sync
end
git "/home/vagrant/swift/llbuild" do
  repository "https://github.com/apple/swift-llbuild.git"
  user "vagrant"
  group "vagrant"
  action :sync
end
git "/home/vagrant/swift/swiftpm" do
  repository "https://github.com/apple/swift-package-manager.git"
  user "vagrant"
  group "vagrant"
  action :sync
end
git "/home/vagrant/swift/swift-corelibs-xctest" do
  repository "https://github.com/apple/swift-corelibs-xctest.git"
  user "vagrant"
  group "vagrant"
  action :sync
end
git "/home/vagrant/swift/swift-corelibs-foundation" do
  repository "https://github.com/apple/swift-corelibs-foundation.git"
  user "vagrant"
  group "vagrant"
  action :sync
end

execute "Execute Swift-Build" do
  cwd "/home/vagrant/swift"
  command " sudo ./swift/utils/build-script"
  user "root"
  group "root"
  action :run
end
