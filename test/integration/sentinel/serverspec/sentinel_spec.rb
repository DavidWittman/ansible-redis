require 'spec_helper'

describe 'Redis' do
  describe service('sentinel_26379') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(26379) do
    it { should be_listening.on('0.0.0.0').with('tcp') }
  end

  describe file('/etc/redis/sentinel_26379.conf') do
    it { should be_file }
    it { should be_owned_by 'redis' }
    its(:content) { should include "include /etc/redis/sentinel_26379.include.conf" }
  end

  describe file('/etc/redis/sentinel_26379.include.conf') do
    it { should be_file }
    it { should be_owned_by 'redis' }
    its(:content) { should include "port 26379" }
  end

  describe file('/etc/redis/sentinel_26379_config.sh') do
    it { should be_file }
    it { should be_owned_by 'redis' }
    it { should be_executable.by('group') }
    its(:content) { should include "sentinel monitor master01 `dig +short localhost` 6379 2" }
  end

  describe file('/var/run/redis/sentinel_26379.pid') do
    it { should be_file }
    it { should be_owned_by 'redis' }
    its(:size) { should > 0 }
  end
end
