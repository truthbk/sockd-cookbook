id = 'sockd'

build_essential 'install compilation tools'

node[id]['packages'].each do |pkg_name|
  package pkg_name do
    action :install
  end
end

directory node[id]['install_dir'] do
  action :create
end

ark 'dante' do
  url node[id]['url'] % { version: node[id]['version'] }
  version node[id]['version']
  checksum node[id]['checksum']
  action :install
  notifies :run, 'execute[configure dante]'
  notifies :run, 'execute[make dante]'
  notifies :run, 'execute[checkinstall dante]'
end

execute 'configure dante' do
  command "./configure --prefix=#{node[id]['install_dir']}"
  cwd ::File.join(node['ark']['prefix_home'], 'dante')
  action :nothing
end

execute 'make dante' do
  command 'make'
  cwd ::File.join(node['ark']['prefix_home'], 'dante')
  action :nothing
end

execute 'checkinstall dante' do
  command 'checkinstall'
  cwd ::File.join(node['ark']['prefix_home'], 'dante')
  action :nothing
end

internal_interface = node[id]['internal_interface']

if internal_interface.nil?
  ruby_block 'detect internal interface' do
    block do
      internal_interface = `ip route | awk '/default/ { print $5}'`.strip
    end
    action :run
  end
end

external_interface = node[id]['external_interface']

if external_interface.nil?
  ruby_block 'detect external interface' do
    block do
      external_interface = `ip route | awk '/default/ { print $5}'`.strip
    end
    action :run
  end
end

template node[id]['config_file'] do
  source 'sockd.conf.erb'
  variables lazy {
    {
      internal_interface: internal_interface,
      external_interface: external_interface,
      port: node[id]['port']
    }
  }
  action :create
end

pwd_file = ::File.join(node[id]['install_dir'], 'sockd.passwd')
secret = ::ChefCookbook::Secret::Helper.new(node)

require 'unix_crypt'

passwd_entries = secret.get('sockd:users').map do |sockd_user, sockd_password|
  {
    user: sockd_user,
    pwd_encrypted: UnixCrypt::MD5.build(sockd_password)
  }
end

template pwd_file do
  source 'sockd.passwd.erb'
  variables(
    entries: passwd_entries
  )
  sensitive true
  not_if { ::File.exist?(pwd_file) }
  action :create
end

template '/etc/pam.d/sockd' do
  source 'sockd.pam.erb'
  variables(
    pwd_file: pwd_file
  )
  action :create
end

systemd_unit 'sockd.service' do
  content({
    Unit: {
      Description: 'Dante Proxy Server',
      After: 'multi-user.target',
    },
    Service: {
      Type: 'forking',
      ExecStart: "#{node[id]['install_dir']}/sbin/sockd -f #{node[id]['config_file']} -D",
      PIDFile: '/var/run/sockd.pid',
      TimeoutSec: '10s',
      User: 'root',
      Restart: 'always'
    },
    Install: {
      WantedBy: 'multi-user.target',
      Alias: 'dante.service'
    }
  })
  if ::Chef::VERSION >= 14.0
    verify false
  end
  action [:create, :enable, :start]
end
