group { "puppet":
  ensure => "present",
}

File { owner => 0, group => 0, mode => 0644 }

file { '/etc/motd':
  content => "Welcome to your NEW Vagrant-built virtual machine!
              Managed by Puppet.\n"
}

include jenkins
include git

# don't use a firewall, see http://stackoverflow.com/questions/5984217
service { iptables: ensure => stopped }

# Install git and dependencies, see
# https://github.com/jenkinsci/puppet-jenkins/issues/78
jenkins::plugin { 'git': }
jenkins::plugin { 'ssh-credentials': }
jenkins::plugin { 'scm-api': }
jenkins::plugin { 'credentials': }
jenkins::plugin { 'multiple-scms': }
jenkins::plugin { 'parameterized-trigger': }
jenkins::plugin { 'git-client': }
