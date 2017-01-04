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
# 設定
REDMINE_HOME = "/var/lib/redmine"
REDMINE_VERSION = "3.3.1-stable"

# ImageMagick,ヘッダファイル,日本語フォント類のインストール
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

# redmineをSVNリポジトリからダウンロードする
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

# redmineで使用するgemパッケージをインストールする
rbenv_script "bundle install" do
  cwd "#{REDMINE_HOME}"
  code %{bundle install --without development test --path vendor/bundle}
end

# redmineの初期設定を行う
rbenv_script "init redmine" do
  cwd "#{REDMINE_HOME}"
  code <<-EOC
        bundle exec rake generate_secret_token
        RAILS_ENV=production bundle exec rake db:migrate
    EOC
end

# redmineのディレクトリをapacheユーザへ変更
execute "change redmine dir" do
  cwd "#{REDMINE_HOME}"
  command "chown -R apache:apache #{REDMINE_HOME}"
end

# railsアプリケーションとしての設定
include_recipe "rails"

web_app "redmine" do
  cookbook "passenger"
  template "web_app.conf.erb"
  docroot "#{REDMINE_HOME}/public"
  servername "hogehoge"
  server_alias ["fugafuga", "hogefuga"]
  rails_env "production"
end
