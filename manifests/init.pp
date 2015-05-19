## Poodle Fix
## Nikolay
## 

class poodle_fix (
$skip_poodle  = true,
) {

# Requirements
  package { 'lsof': ensure => 'installed' }
  package { 'openssl': ensure => 'latest' }

if $skip_poodle == true {
  warning("Poodle Fix will be skipped [skip_pood=${skip_poodle}]")
}
else {
  file { '/tmp/disable_sslv3.sh':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/poodle_fix/disable_sslv3.sh',
    require => Package['lsof', 'openssl'],
  }
  exec { 'Disable_SSLv3':
    path      => [ '/bin', '/usr/bin' ],
    command   => '/tmp/disable_sslv3.sh ',
    logoutput => true,
    unless    => 'test -f /tmp/poodle_fixed',
  }
  }
}
