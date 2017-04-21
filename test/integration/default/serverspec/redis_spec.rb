require 'spec_helper'

is_systemd_init = File.realpath('/proc/1/exe').include?('systemd')
is_sysctl_writable = test('w', '/proc/sys')

describe 'Redis' do
  describe service('redis_6379'), if: !is_systemd_init do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('redis_6379'), if: is_systemd_init  do
    #it { should be_enabled.under('systemd') }
    it { should be_running.under('systemd') }
  end

  describe port(6379) do
    it { should be_listening.on('0.0.0.0').with('tcp') }
  end

  describe file('/etc/redis/6379.conf') do
    it { should be_file }
    it { should be_owned_by 'redis' }
    its(:content) { should match /port 6379/ }
  end

  describe file('/var/run/redis/6379.pid'), if: !is_systemd_init  do
    it { should be_file }
    it { should be_owned_by 'redis' }
    its(:size) { should > 0 }
  end

  describe file('/proc/sys/vm/overcommit_memory'), if: is_sysctl_writable do
    it { should be_file }
    it { should contain '1' }
  end
end
