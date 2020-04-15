require 'spec_helper'

describe 'Redis' do
  describe service('redis_6379') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(6379) do
    it { should be_listening.on('0.0.0.0').with('tcp') }
  end

  describe file('/etc/redis/6379.conf') do
    it { should be_file }
    it { should be_owned_by 'redis' }
    its(:content) { should match /port 6379/ }
  end

  describe file('/var/run/redis/6379.pid') do
    it { should be_file }
    it { should be_owned_by 'redis' }
    its(:size) { should > 0 }
  end

  describe file('/proc/sys/vm/overcommit_memory') do
    it { should be_file }
    it { should contain '1' }
  end

  describe file('/usr/bin/redis-server') do
    it { should be_symlink }
  end

  describe file('/usr/bin/redis-cli') do
    it { should be_symlink }
  end
end
