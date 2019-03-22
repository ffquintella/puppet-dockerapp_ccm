#
# == Class: dockerapp_ccm
#
# Installs and configures the ccm app
#
# === Parameters
#
# [*version*]
#   Docker hub version of the image to be installed. Check ffquinteall/ccm at docker hub to see the avaliable options
#
# [*ports*]
#   Ports to be used by the app
#
# [*masterkey*]
#   The encryption masterkey
#
# [*service_name*] (optional)
#   The name to be used for the service and directories 
#
class dockerapp_ccm  (
  $version = '1.5.51',
  $ports = [ '4443:443'],
  $redis_server = undef,
  $masterkey = undef,
  $service_name = 'ccm'
  ){

  include 'dockerapp'

  #if( !defined($redis_server) ){
  #  fail('Redis server must be defined to the app work')
  #}

  $ccm_masterkey = "<?php
  function get_master_key(){ return '${masterkey}';}
  "

  $dir_owner = 999

  #Extra packages
  package{'redis-tools':}

  #CCM 
  $image = "ffquintella/ccm:${version}"

  $data_dir = $::dockerapp::params::data_dir
  $config_dir = $::dockerapp::params::config_dir
  $scripts_dir = $::dockerapp::params::scripts_dir
  $lib_dir = $::dockerapp::params::lib_dir
  $log_dir = $::dockerapp::params::log_dir

  $conf_datadir = "${data_dir}/${service_name}"
  $conf_configdir = "${config_dir}/${service_name}"
  $conf_scriptsdir = "${scripts_dir}/${service_name}"
  $conf_libdir = "${lib_dir}/${service_name}"
  $conf_logdir = "${log_dir}/${service_name}"

  file {"${conf_logdir}/nginx":
    ensure  => directory,
    require => File[$conf_logdir],
  }
  file {"${conf_logdir}/php-fpm":
    ensure  => directory,
    require => File[$conf_logdir],
  }
  file {"${conf_logdir}/ccm":
    ensure  => directory,
    require => File[$conf_logdir],
  }
  file {"${conf_configdir}/masterkey.php":
    require => File[$conf_configdir],
    content => $ccm_masterkey,
  }

  $volumes = [
    "${conf_logdir}/nginx:/var/log/nginx",
    "${conf_logdir}/php-fpm:/var/log/php-fpm",
    "${conf_logdir}/ccm:/var/log/ccm",
    "${conf_configdir}/masterkey.php:/app/masterkey.php",
  ]

  $envs = [
    'FACTER_TIMEZONE=America/Sao_Paulo',
    'FACTER_LOG_LEVEL=DEBUG',
    'FACTER_SESSION_TIME=600',
    'FACTER_SMTP_SERVER=smtp.ccb.com',
    'FACTER_EMAIL_FROM=ccm@abc.com',
    'FACTER_EMAIL_FROM_NAME=CCM SERVER',
    'FACTER_HTTP_TIMEOUT=15',
    'FACTER_PHP_TIMEOUT=300',
    'FACTER_HTTPS_REQUIRED=true',
    'FACTER_AUTHENTICATION_REQUIRED=true',
    'FACTER_PASS_SIZE=25',
    'FACTER_USER_PASS_SIZE=15',
    'FACTER_APP_KEY_SIZE=32',
    'FACTER_CACHE_TIMEOUT=1200',
    'FACTER_CACHE_DNS_TIMEOUT=600',
    "FACTER_REDIS_SERVER=${redis_server}",
    'FACTER_REDIS_PORT=6379',
    'FACTER_REDIS_DATABASE=1',
  ]

  dockerapp::run {$service_name:
    image        => $image,
    ports        => $ports,
    volumes      => $volumes,
    environments => $envs,
  }


}

