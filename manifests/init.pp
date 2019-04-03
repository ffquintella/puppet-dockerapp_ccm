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
# [*redis_slave_server*] (optional)
#   A secundary redir server for HA
#
# [*redis_port*] (optional)
#   The tcp port of the redis server
#
# [*redis_slave_port*] (optional)
#   The tcp port of the redis slave server
#
# [*redis_database*] (optional)
#   The database to use in redis
#
# [*redis_secure_connection*] (optional)
#   Determines if the redis connection should be criptografed (spiped)
#
# [*redis_secure_connection_key*] (optional)
#   The key used to secure the connection (spiped key)
#
# [*masterkey*]
#   The encryption masterkey
#
# [*service_name*] (optional)
#   The name to be used for the service and directories 
#
# [*smtp_server*] 
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
# [*ssl_cert*] (optional) (string)
#   The ssl certificate 
#
# [*ssl_key*] (optional) (string)
#   The ssl key
#
# [*ldap_enabled*] (optional) (boolean)
#   Enable or not the ldap authentication
#
# [*ldap_main_server*] (optional) (string)
#   The URI of the principal ldap server
#
# [*ldap_secundary_server*] (optional) (string)
#   The URI of the secundary ldap server
#
# [*ldap_third_server*] (optional) (string)
#   The URI of the third ldap server
#
# [*ldap_port*] (optional) (string)
#   The port being used by the ldap servers (must be the same for all)
#
# [*ldap_user_prefix*] (optional) (string)
#   The ldap prefix for the users (@prefix.com)
#
# [*vault_enabled*] (optional) (boolean)
#   If the integration with the vault (plugin) must be enabled or not
#
# [*vault_type*] (optional) (string)
#   The vault type (plugin name)
#
# [*vault_main_server*] (optional) (string)
#   Principal vault server
#
# [*vault_secundary_server*] (optional) (string)
#   Secundary vault server
#
# [*vault_base_uri*] (optional) (string)
#   The base uri used by the vault
#
# [*vault_api_token*] (optional) (string)
#   Authentication api token used by the vault
#
class dockerapp_ccm  (
  $version = '1.5.51',
  $ports = ['4443:443'],
  $redis_server = undef,
  $redis_slave_server = undef,
  $redis_port = '6379',
  $redis_slave_port = '6379',
  $redis_database = '1',
  Boolean $redis_secure_connection = false,
  $redis_secure_connection_key = undef,
  $master_key = undef,
  $service_name = 'ccm',
  $smtp_server = undef,
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
  $ssl_cert = undef,
  $ssl_key = undef,
  $ldap_enabled = false,
  $ldap_main_server = '',
  $ldap_secundary_server = '',
  $ldap_third_server = '',
  $ldap_port = 636,
  $ldap_user_prefix = '',
  $vault_enabled = false,
  $vault_type = 'pmp',
  $vault_main_server = '',
  $vault_secundary_server = '',
  $vault_base_uri = '',
  $vault_api_token = ''
  ){

  include 'dockerapp'

  #if( !defined($redis_server) ){
  #  fail('Redis server must be defined to the app work')
  #}

  $ccm_masterkey = "<?php
  function get_master_key(){ return '${master_key}';}
  "

  $dir_owner = 999

  #Extra packages

  if($::osfamily == 'RedHat'){
    package{'epel-release':}
    -> package{'redis':}
  }
  if($::osfamily == 'Debian'){
    package{'redis-tools':}
  }

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

  $log_dir_owner = 999

  file {"${conf_logdir}/nginx":
    ensure  => directory,
    require => File[$conf_logdir],
    owner   => $log_dir_owner,
  }
  file {"${conf_logdir}/php-fpm":
    ensure  => directory,
    require => File[$conf_logdir],
    owner   => $log_dir_owner,
  }
  file {"${conf_logdir}/ccm":
    ensure  => directory,
    require => File[$conf_logdir],
    owner   => $log_dir_owner,
  }
  file {"${conf_configdir}/masterkey.php":
    require => File[$conf_configdir],
    content => $ccm_masterkey,
  }
  file {'/usr/local/bin/ccm_data':
    content => "#!/bin/bash 
  docker exec -ti ${service_name} /usr/local/bin/ccm_data \$@",
    mode    => '0755',
  }

  if $ssl_cert != undef {
    if $ssl_key == undef { fail('With ssl_cert defined ssl_key is mandatory!') }

    file{"${conf_configdir}/certs":
      ensure  => directory,
      require => File[$conf_configdir],
    }
    -> file{"${conf_configdir}/certs/ccm_server.crt":
      content => $ssl_cert,
    }
    -> file{"${conf_configdir}/certs/ccm_server.key":
      content => $ssl_key,
    }

    $volumes = [
      "${conf_configdir}/certs/ccm_server.crt:/etc/pki/tls/certs/ccm_server.crt",
      "${conf_configdir}/certs/ccm_server.key:/etc/pki/tls/private/ccm_server.key",
      "${conf_logdir}/nginx:/var/log/nginx",
      "${conf_logdir}/php-fpm:/var/log/php-fpm",
      "${conf_logdir}/ccm:/var/log/ccm",
      "${conf_configdir}/masterkey.php:/app/masterkey.php",
    ]
  }else{
    $volumes = [
      "${conf_logdir}/nginx:/var/log/nginx",
      "${conf_logdir}/php-fpm:/var/log/php-fpm",
      "${conf_logdir}/ccm:/var/log/ccm",
      "${conf_configdir}/masterkey.php:/app/masterkey.php",
    ]
  }

  $sp_service_name = "${service_name}-spiped"

  $envs = [
    "FACTER_TIMEZONE=${timezone}",
    "FACTER_LOG_LEVEL=${log_level}",
    "FACTER_SESSION_TIME=${session_time}",
    "FACTER_SMTP_SERVER=${smtp_server}",
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
    "FACTER_REDIS_SLAVE_SERVER=${redis_slave_server}",
    "FACTER_REDIS_PORT=${redis_port}",
    "FACTER_REDIS_SLAVE_PORT=${redis_slave_port}",
    "FACTER_REDIS_DATABASE=${redis_database}",
    "FACTER_REDIS_SECURE_CONNECTION=${redis_secure_connection}",
    "FACTER_SPIPED_SERVICE_NAME=${sp_service_name}",
    "FACTER_LDAP_ENABLED=${ldap_enabled}",
    "FACTER_LDAP_MAIN_SERVER=${ldap_main_server}",
    "FACTER_LDAP_SECUNDARY_SERVER=${ldap_secundary_server}",
    "FACTER_LDAP_THIRD_SERVER=${ldap_third_server}",
    "FACTER_LDAP_PORT=${ldap_port}",
    "FACTER_LDAP_USER_PREFIX=${ldap_user_prefix}",
    "FACTER_VAULT_ENABLED=${vault_enabled}",
    "FACTER_VAULT_TYPE=${vault_type}",
    "FACTER_VAULT_MAIN_SERVER=${vault_main_server}",
    "FACTER_VAULT_SECUNDARY_SERVER=${vault_secundary_server}",
    "FACTER_VAULT_BASE_URI=${vault_base_uri}",
    "FACTER_VAULT_API_TOKEN=${vault_api_token}",
  ]

  if $redis_secure_connection == true {

    $spiped_version = '1.6'

    $sp_key = $redis_secure_connection_key

    $sp_redis_port_master = 16379
    $sp_redis_port_slave = 26379

    ::dockerapp_spiped {"${sp_service_name}-master":
      version  => $spiped_version,
      port_in  => $sp_redis_port_master,
      port_out => $redis_port,
      ip_out   => $redis_server,
      type     => 'out',
      key      => $sp_key,
    }

    if $redis_slave_server != undef {
      ::dockerapp_spiped {"${sp_service_name}-slave":
        version  => $spiped_version,
        port_in  => $sp_redis_port_slave,
        port_out => $redis_slave_port,
        ip_out   => $redis_slave_server,
        type     => 'out',
        key      => $sp_key,
      }

      $links = ["${sp_service_name}-master","${sp_service_name}-slave"]
      $dapp_require = [Dockerapp_spiped["${sp_service_name}-master"], Dockerapp_spiped["${sp_service_name}-slave"]]
    }else{
      $links = ["${sp_service_name}-master"]
      $dapp_require = [Dockerapp_spiped["${sp_service_name}-master"]]
    }

    dockerapp::run {$service_name:
      image        => $image,
      ports        => $ports,
      volumes      => $volumes,
      environments => $envs,
      links        => $links,
      require      => $dapp_require,
    }

  }else{
    dockerapp::run {$service_name:
      image        => $image,
      ports        => $ports,
      volumes      => $volumes,
      environments => $envs,
    }
  }


}

