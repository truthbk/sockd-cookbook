name 'sockd'
maintainer 'Alexander Pyatkin'
maintainer_email 'aspyatkin@gmail.com'
license 'MIT'
version '0.1.2'
description 'Install and configure Dante - A free SOCKS server'

recipe 'sockd::default', 'Install and configure Dante - A free SOCKS server'

source_url 'https://github.com/aspyatkin/sockd-cookbook' if respond_to?(:source_url)

supports 'ubuntu', '>= 16.04'

gem 'unix-crypt'

depends 'build-essential', '>= 5.0'
depends 'ark', '~> 4.0.0'
depends 'secret', '~> 1.0.0'

chef_version '>= 12.14' if respond_to?(:chef_version)
