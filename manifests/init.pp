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
# [*redis_server*]
#   The fqnd of the redis server 
#
# [*redis_port*] (optional)
#   The tcp port of the redis server
#
# [*redis_database*] (optional)
#   The database to use in redis
#
# [*masterkey*]
#   The encryption masterkey
#
# [*service_name*] (optional)
#   The name to be used for the service and directories 
#
# [*smpt_server*] 
#   The server to send e-mails  
#
# [*email_from*] 
#   The email to use on the from field
#
# [*email_name*] 
#   The name to appear on the e-mails
#
# [*timezone*] (optional)
#   The php timezone
#
# [*log_level*] (optional)
#   The log verbosity INFO|DEBUG
#
# [*session_time*] (optional)
#   The session time in seconds
#
# [*http_timeout*] (optional)
#   The http timeout in seconds
#
# [*php_timeout*] (optional)
#   The php timeout in seconds
#
# [*ssl_required*] (optional)
#   If ssl is required. Only disable this in development environment
#
# [*auth_required*] (optional)
#   If authentication is required. Only disable this in development environment
#
# [*passwd_size*] (optional)
#   The size of the generated passwords
#
# [*user_passwd_size*] (optional)
#   The size of the user required password
#
# [*app_key_size*] (optional)
#   The size of the app key
#
# [*cache_timeout*] (optional)
#   The time in seconds to keep the cached data
#
# [*cache_dns_timeout*] (optional)
#   The time in seconds to keep the cached dns results
#
class dockerapp_ccm  (
  $version = '1.5.51',
  $ports = ['4443:443'],
  $redis_server = undef,
  $redis_port = '6379',
  $redis_database = '1',
  $masterkey = undef,
  $service_name = 'ccm',
  $smpt_server = undef,
  $email_from = undef,
  $email_name = undef,
  $timezone = 'America/Sao_Paulo',
  $log_level = 'INFO',
  $session_time = '600',
  $http_timeout = '15',
  $php_timeout = '300',
  $ssl_required = true,
  $auth_required = true,
  $passwd_size = '25',
  $user_passwd_size = '15',
  $app_key_size = '32',
  $cache_timeout = '1200',
  $cache_dns_timeout = '600',
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
    "FACTER_TIMEZONE=${timezone}",
    "FACTER_LOG_LEVEL=${log_level}",
    "FACTER_SESSION_TIME=${session_time}",
    "FACTER_SMTP_SERVER=${smpt_server}",
    "FACTER_EMAIL_FROM=${email_from}",
    "FACTER_EMAIL_FROM_NAME=${email_name}",
    "FACTER_HTTP_TIMEOUT=${http_timeout}",
    "FACTER_PHP_TIMEOUT=${php_timeout}",
    "FACTER_HTTPS_REQUIRED=${ssl_required}",
    "FACTER_AUTHENTICATION_REQUIRED=${auth_required}",
    "FACTER_PASS_SIZE=${passwd_size}",
    "FACTER_USER_PASS_SIZE=${user_passwd_size}",
    "FACTER_APP_KEY_SIZE=${app_key_size}",
    "FACTER_CACHE_TIMEOUT=${cache_timeout}",
    "FACTER_CACHE_DNS_TIMEOUT=${cache_dns_timeout}",
    "FACTER_REDIS_SERVER=${redis_server}",
    "FACTER_REDIS_PORT=${redis_port}",
    "FACTER_REDIS_DATABASE=${redis_database}",
  ]

  dockerapp::run {$service_name:
    image        => $image,
    ports        => $ports,
    volumes      => $volumes,
    environments => $envs,
  }


}

