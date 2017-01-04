# coding: cp932
#
# Cookbook Name:: redmine-mysql
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "mysql::server"

cookbook_file "/etc/mysql/conf.d/mysql.cnf" do
    souce "mysql.cnf"
    mode 0644
    notifies :restart, "service[mysql]", :immediately
end

include_recipe "database::mysql"

# �R�l�N�V������`
mysql_connection_info = {
    :host => "localhost",
    :username => "root",
    :password => node['mysql']['server_root_password']
}

# redmine�p�̃f�[�^�x�[�X�쐬
mysql_database "db_redmine" do
    connection mysql_connection_info
    action :create
end

# redmine�p�f�[�^�x�[�X�̃��[�U���쐬
mysql_database_user "user_redmine" do
    connection mysql_connection_info
    password "xxxxxxxx"
    database_name "db_redmine"
    privileges [:all]
    action [:create, :grant]
end
