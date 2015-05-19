#!/bin/bash

## Disable Apache SSLv2 and SSLv3
## Nikolay

## Debug mode (uncomment to debug)
#set -x

# Check if using mod_ssl
function func_check_modssl {
check_lsof=$(/usr/sbin/lsof |grep mod_ssl|grep httpd)
local status=$?
if [ $status -eq 0 ]; then
  echo "mod_ssl is enabled, moving forward..."
  func_check_modssl=1 
else
  echo "mod_ssl is not enabled $1" >&2
  exit 0 
fi
return $status
}

# Check if SSLv2 and SSLv3 are already disabled
func_check_ssl_disabled () {
status=""
version_check=$(/bin/cat /etc/httpd/conf.d/*.conf |grep "SSLv2" |grep "SSLv3")
local status=$?
if [ $status -eq 0 ]; then
  echo "SSLv2 and SSLv3 are already disabled"
  touch /tmp/poodle_fixed
  exit 0 
else 
  #return 0
  func_check_ssl_disabled=1
fi
}

# Check for multiple virtual hosts
func_check_vhosts () {
status=""
check_sslengine=$(cat /etc/httpd/conf.d/*.conf |grep -ci "sslengine on")
local status=$?
if [ $check_sslengine -gt 1 ]; then
  echo "Found more than one virtual host with SSL. Please configure the server manually"
  exit 1
else
  #return $status 
  func_check_vhosts=1
fi
}

# Compare and decide if should run 
func_compare () {
if (( $func_check_modssl == $func_check_ssl_disabled == $func_check_vhosts )); then
  echo "Disabling SSLv3"
  /bin/sed -i.bak "s/SSLProtocol.*/SSLProtocol all -SSLv2 -SSLv3/g" $(/bin/grep -l SSLProtocol /etc/httpd/conf.d/*.conf)
  echo "Reloading Apache ..."
  /sbin/service httpd reload
  echo "Creating control file..."
  touch /tmp/poodle_fixed
else 
  echo "Found more than one virtual host with SSL. Please configure the server manually"
  exit 1
fi
}

func_check_modssl
func_check_ssl_disabled
func_check_vhosts
func_compare

#set +x
