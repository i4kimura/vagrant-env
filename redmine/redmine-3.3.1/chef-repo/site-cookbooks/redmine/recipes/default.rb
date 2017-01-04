# coding: cp932
#
# Cookbook Name:: redmine
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# coding: cp932
# �ݒ�
REDMINE_HOME = "/var/lib/redmine"
REDMINE_VERSION = "3.3.1-stable"

# ImageMagick,�w�b�_�t�@�C��,���{��t�H���g�ނ̃C���X�g�[��
package "ImageMagick" do
  action :install
end
package "ImageMagick-devel" do
  action :install
end
package "ipa-pgothic-fonts" do
  action :install
end
package "libuuid-devel" do
  action :install
end
package "wget" do
  action :install
end

# redmine��SVN���|�W�g������_�E�����[�h����
subversion "redmine" do
  repository "http://svn.redmine.org/redmine/branches/#{REDMINE_VERSION}"
  destination "#{REDMINE_HOME}"
  action :sync
end

template "#{REDMINE_HOME}/config/configuration.yml" do
  owner "root"
  mode 0644
  source "configuration.yml.erb
end

template "#{REDMINE_HOME}/config/database.yml" do
  owner "root"
  mode 0644
  source "database.yml.erb"
end

# redmine�Ŏg�p����gem�p�b�P�[�W���C���X�g�[������
rbenv_script "bundle install" do
  cwd "#{REDMINE_HOME}"
  code %{bundle install --without development test --path vendor/bundle}
end

# redmine�̏����ݒ���s��
rbenv_script "init redmine" do
  cwd "#{REDMINE_HOME}"
  code <<-EOC
        bundle exec rake generate_secret_token
        RAILS_ENV=production bundle exec rake db:migrate
    EOC
end

# redmine�̃f�B���N�g����apache���[�U�֕ύX
execute "change redmine dir" do
  cwd "#{REDMINE_HOME}"
  command "chown -R apache:apache #{REDMINE_HOME}"
end

# rails�A�v���P�[�V�����Ƃ��Ă̐ݒ�
include_recipe "rails"

web_app "redmine" do
  cookbook "passenger"
  template "web_app.conf.erb"
  docroot "#{REDMINE_HOME}/public"
  servername "hogehoge"
  server_alias ["fugafuga", "hogefuga"]
  rails_env "production"
end
