#
# Author:: Joe Heung <joe.heung@logentries.com>
# Cookbook Name:: le_chef
# Recipe:: default
#
# Copyright 2014 Logentries, JLizard
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if platform_family?('rhel')
  yum_key "RPM-GPG-KEY-logentries" do
    url 'http://rep.logentries.com/RPM-GPG-KEY-logentries'
    action :add
  end

  yum_repository 'logentries' do
    repo_name 'logentries'
    description 'Logentries repo'
    url 'http://rep.logentries.com/rh/\$basearch'
    key 'RPM-GPG-KEY-logentries'
    action :add
  end
end

if platform_family?('debian')
  apt_repository 'logentries' do
    uri          'http://rep.logentries.com/'
    distribution node['lsb']['codename']
    components   ['main']
    keyserver    'pgp.mit.edu'
    key          'C43C79AD'
  end
end

package 'logentries'

execute "le register --user-key #{node['le']['account_key']} --name='#{node['le'][:hostname]}'" do
  not_if 'le whoami'
end

package 'logentries-daemon'

class Chef::Recipe
  include FollowLogs
end

# Follow logs from the JSON config
follow_logs()

# Start the service
service 'logentries' do
  supports :stop => true, :start => true, :restart => true
  action [ :restart ]
end
