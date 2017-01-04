#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2010, FindsYou Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "ruby_rbenv::system"
include_recipe "ruby_build"

rbenv_ruby "1.9.3-p484"
rbenv_ruby "2.0.0-p353"
rbenv_ruby "2.1.0"
rbenv_global "1.9.3-p484"

# rbenv /usr/local/rbenv
group "rbenv" do
    action :create
    members "vagrant"
    append true
end

execute "change install ruby group" do
  command "chown -R :rbenv /usr/local/rbenv"
  action :run
end

rbenv_gem "bundler" do
  rbenv_version "1.9.3-p484"
end
rbenv_gem "bundler" do
  rbenv_version "2.0.0-p484"
end
rbenv_gem "bundler" do
  rbenv_version "2.1.0"
end

# file '/etc/yum.conf' do
#   _file = Chef::Util::FileEdit.new(path)
#   _file.search_file_replace_line('exclude=kernel',        '#exclude=kernel\n')
#   content _file.send(:contents).join
#   action :create
# end.run_action(:create)
