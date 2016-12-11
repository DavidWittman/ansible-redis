require 'spec_helper'
require 'json'

describe 'Redis' do
  describe service('redis_6379') do
    it { should be_running }
  end

  describe service('sentinel_26379') do
    it { should be_running }
  end

  describe command('/etc/ansible/facts.d/redis_6379.fact') do
    its(:exit_status) { should eq 0 }

    it 'should return redis facts' do
      facts = JSON.parse(subject.stdout)
      facts.should have_key('redis_version')
    end
  end

  describe command('/etc/ansible/facts.d/redis_sentinel_26379.fact') do
    its(:exit_status) { should eq 0 }

    it 'should return sentinel facts' do
      facts = JSON.parse(subject.stdout)
      facts.should have_key('sentinel_masters')
    end
  end
end
