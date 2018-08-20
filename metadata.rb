name 'sockd'
maintainer 'Alexander Pyatkin'
maintainer_email 'aspyatkin@gmail.com'
license 'MIT'
version '0.0.1'
description 'Install and configure Dante - A free SOCKS server'

recipe 'sockd::default', 'Install and configure Dante - A free SOCKS server'

source_url 'https://github.com/aspyatkin/sockd-cookbook' if respond_to?(:source_url)

supports 'ubuntu'
