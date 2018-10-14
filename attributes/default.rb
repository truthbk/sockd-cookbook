id = 'sockd'

default[id]['url'] = 'https://www.inet.no/dante/files/dante-%{version}.tar.gz'
default[id]['version'] = '1.4.2'
default[id]['checksum'] = '4c97cff23e5c9b00ca1ec8a95ab22972813921d7fbf60fc453e3e06382fc38a7'

default[id]['install_dir'] = '/opt/dante'
default[id]['config_file'] = '/etc/sockd.conf'

default[id]['packages'] = %w(
  libpam-pwdfile
  libwrap0-dev
  libpam0g-dev
  checkinstall
)

default[id]['internal_interface'] = nil  # autodetect
default[id]['external_interface'] = nil  # autodetect
default[id]['port'] = 1080
