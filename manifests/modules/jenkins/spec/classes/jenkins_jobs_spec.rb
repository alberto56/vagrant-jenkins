require 'spec_helper'

describe 'jenkins', :type => :module  do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }

  context 'jobs' do
    context 'default' do
      it { should contain_class('jenkins::jobs') }
    end

    context 'with one job' do
      let(:params) { { :job_hash => { 'build' => { 'config' => '<xml/>' } } } }
      it { should contain_jenkins__job('build').with_config('<xml/>') }
    end

    context 'with cli disabled' do
      let(:params) { { :service_ensure => 'stopped',
                       :cli => false,
                       :job_hash => { 'build' => { 'config' => '<xml/>' } } } }
      it { expect { should compile }.to raise_error }
    end

  end

end
