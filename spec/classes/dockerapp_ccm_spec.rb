require 'spec_helper'

describe '::dockerapp_ccm' do
  let(:node) { 'node1.test.com' }
  let(:params) do
    {
      version: '1.4.1',
      redis_server: 'redis-123.com',
      masterkey: 'abcv1263547563',
      ports: ['8443:443']
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


  it { is_expected.to contain_dockerapp__run('ccm').with(
    'image' => 'ffquintella/ccm:1.4.1',
    'ports' => ['8443:443'],
    ) }
end
