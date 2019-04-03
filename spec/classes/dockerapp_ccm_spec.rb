require 'spec_helper'

describe '::dockerapp_ccm' do
  let(:node) { 'node1.test.com' }
  let(:params) do
    {
      version: '1.4.1',
      redis_server: 'redis-123.com',
      master_key: 'abcv1263547563',
      ports: ['8443:443'],
      log_level: 'DEBUG',
      smtp_server: 'smtp1',
      email_from: 'test@mail.com',
      email_name: 'testMail',
      redis_slave_server: 'salve1',
      redis_port: '26379',
      redis_slave_port: '36379',
      redis_database: '5',
      ldap_enabled: true,
      ldap_main_server: 'ldap1',
      ldap_secundary_server: 'ldap2',
      ldap_third_server: 'ldap3',
      ldap_port: 636,
      ldap_user_prefix: '@ldap',
      vault_enabled: true,
      vault_type: 'pmp',
      vault_main_server: 'vault1',
      vault_secundary_server: 'vault2',
      vault_base_uri: '/api',
      vault_api_token: 'api-key-1',
    }
  end

  let(:facts) do
    {
      id: 'root',
      kernel: 'Linux',
      osfamily: 'RedHat',
      operatingsystem: 'OracleLinux',
      operatingsystemmajrelease: '7',
      architecture: 'x86_64',
      os:
      {
        'family'     => 'RedHat',
        'name'       => 'OracleLinux',
        'release'    =>
        {
          'major' => '7',
          'minor' => '5',
        },
      },
      path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      is_pe: false,
    }
  end

  it { is_expected.to compile }
  it { is_expected.to contain_class('dockerapp') }
  it { is_expected.to contain_class('docker') }
  it { is_expected.to contain_file('/srv/application-data/ccm') }
  it { is_expected.to contain_file('/srv/application-config/ccm') }
  it { is_expected.to contain_file('/srv/application-lib/ccm') }
  it { is_expected.to contain_file('/srv/application-log/ccm') }
  it { is_expected.to contain_file('/srv/scripts/ccm') }
  it { is_expected.to contain_file('/usr/local/bin/ccm_data') }

  it {
    is_expected.to contain_dockerapp__run('ccm')
      .with(
        image: 'ffquintella/ccm:1.4.1',
        ports: ['8443:443'],
        volumes: [
          '/srv/application-log/ccm/nginx:/var/log/nginx',
          '/srv/application-log/ccm/php-fpm:/var/log/php-fpm',
          '/srv/application-log/ccm/ccm:/var/log/ccm',
          '/srv/application-config/ccm/masterkey.php:/app/masterkey.php',
        ],
        environments: [
          'FACTER_TIMEZONE=America/Sao_Paulo',
          'FACTER_LOG_LEVEL=DEBUG',
          'FACTER_SESSION_TIME=600',
          'FACTER_SMTP_SERVER=smtp1',
          'FACTER_EMAIL_FROM=test@mail.com',
          'FACTER_EMAIL_FROM_NAME=testMail',
          'FACTER_HTTP_TIMEOUT=15',
          'FACTER_PHP_TIMEOUT=300',
          'FACTER_HTTPS_REQUIRED=true',
          'FACTER_AUTHENTICATION_REQUIRED=true',
          'FACTER_PASS_SIZE=25',
          'FACTER_USER_PASS_SIZE=15',
          'FACTER_APP_KEY_SIZE=32',
          'FACTER_CACHE_TIMEOUT=1200',
          'FACTER_CACHE_DNS_TIMEOUT=600',
          'FACTER_REDIS_SERVER=redis-123.com',
          'FACTER_REDIS_SLAVE_SERVER=salve1',
          'FACTER_REDIS_PORT=26379',
          'FACTER_REDIS_SLAVE_PORT=36379',
          'FACTER_REDIS_DATABASE=5',
          'FACTER_REDIS_SECURE_CONNECTION=false',
          'FACTER_SPIPED_SERVICE_NAME=ccm-spiped',
          'FACTER_LDAP_ENABLED=true',
          'FACTER_LDAP_MAIN_SERVER=ldap1',
          'FACTER_LDAP_SECUNDARY_SERVER=ldap2',
          'FACTER_LDAP_THIRD_SERVER=ldap3',
          'FACTER_LDAP_PORT=636',
          'FACTER_LDAP_USER_PREFIX=@ldap',
          'FACTER_VAULT_ENABLED=true',
          'FACTER_VAULT_TYPE=pmp',
          'FACTER_VAULT_MAIN_SERVER=vault1',
          'FACTER_VAULT_SECUNDARY_SERVER=vault2',
          'FACTER_VAULT_BASE_URI=/api',
          'FACTER_VAULT_API_TOKEN=api-key-1',
        ],
      )
  }
end
