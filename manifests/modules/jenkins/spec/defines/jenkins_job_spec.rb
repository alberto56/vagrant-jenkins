require 'spec_helper'

describe 'jenkins::job' do
  let(:title) { 'myjob' }

  describe 'with defaults' do
    let(:params) {{ :config => '' }}
    it { should contain_exec('jenkins create-job myjob') }
    it { should contain_exec('jenkins update-job myjob') }
    it { should contain_exec('jenkins enable-job myjob') }
    it { should_not contain_exec('jenkins disable-job myjob') }
    it { should_not contain_exec('jenkins delete-job myjob') }
  end

  describe 'with job enabled' do
    let(:params) {{ :enabled => 1 , :config => '' }}
    it { should contain_exec('jenkins create-job myjob') }
    it { should contain_exec('jenkins update-job myjob') }
    it { should contain_exec('jenkins enable-job myjob') }
    it { should_not contain_exec('jenkins disable-job myjob') }
    it { should_not contain_exec('jenkins delete-job myjob') }
  end

  describe 'with job disabled' do
    let(:params) {{ :enabled => 0 , :config => '' }}
    it { should contain_exec('jenkins create-job myjob') }
    it { should contain_exec('jenkins update-job myjob') }
    it { should_not contain_exec('jenkins enable-job myjob') }
    it { should contain_exec('jenkins disable-job myjob') }
    it { should_not contain_exec('jenkins delete-job myjob') }
  end

  describe 'with job present' do
    let(:params) {{ :ensure => 'present', :config => '' }}
    it { should contain_exec('jenkins create-job myjob') }
    it { should contain_exec('jenkins update-job myjob') }
    it { should contain_exec('jenkins enable-job myjob') }
    it { should_not contain_exec('jenkins disable-job myjob') }
    it { should_not contain_exec('jenkins delete-job myjob') }
  end

  describe 'with job absent' do
    let(:params) {{ :ensure => 'absent', :config => '' }}
    it { should_not contain_exec('jenkins create-job myjob') }
    it { should_not contain_exec('jenkins update-job myjob') }
    it { should_not contain_exec('jenkins enable-job myjob') }
    it { should_not contain_exec('jenkins disable-job myjob') }
    it { should contain_exec('jenkins delete-job myjob') }
  end

  describe 'with unformatted config' do
    unformatted_config = <<eos
<xml version='1.0' encoding='UTF-8'>
 <notselfclosing></notselfclosing>
 <notempty>...</notempty>
 <anotherempty></anotherempty>
 <quotes>&quot;...&quot;</quotes>
</xml>
eos
    formatted_config = <<eos
<xml version="1.0" encoding="UTF-8">
 <notselfclosing/>
 <notempty>...</notempty>
 <anotherempty/>
 <quotes>"..."</quotes>
</xml>
eos

   let(:params) {{ :ensure => 'present',
                   :config => unformatted_config }}
    it { should contain_file('/tmp/myjob-config.xml')\
      .with_content(formatted_config) }
  end

  describe 'with config with single quotes' do
    quotes = "<xml version='1.0' encoding='UTF-8'></xml>"
    let(:params) {{ :ensure => 'present', :config => quotes }}
    it { should contain_file('/tmp/myjob-config.xml')\
      .with_content(/version="1\.0" encoding="UTF-8"/) }
  end

  describe 'with config with empty tags' do
    empty_tags = '<xml><notempty><empty></empty></notempty><emptytwo></emptytwo></xml>'
    let(:params) {{ :ensure => 'present', :config => empty_tags }}
    it { should contain_file('/tmp/myjob-config.xml')\
      .with_content('<xml><notempty><empty/></notempty><emptytwo/></xml>') }
  end

  describe 'with config with &quot;' do
    quotes = "<config>the dog said &quot;woof&quot;</config>"
    let(:params) {{ :ensure => 'present', :config => quotes }}
    it { should contain_file('/tmp/myjob-config.xml')\
      .with_content('<config>the dog said "woof"</config>') }
  end

end
