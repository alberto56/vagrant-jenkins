group { "puppet":
  ensure => "present",
}

File { owner => 0, group => 0, mode => 0644 }

# see https://wiki.jenkins-ci.org/display/JENKINS/Log+Parser+Plugin
file {'testfile':
  path    => '/tmp/logparser',
  ensure  => present,
  mode    => 0644,
  content => "ok /not really/

# match line starting with 'error ', case-insensitive
error /(?i)^error /

# match line containing '[error]', case-insensitive
error /(?i)\[error\]/

# match line beginning with '[Fail]', case-insensitive
error /(?i)^fail/

# list of warnings here...
warning /[Ww]arning/
warning /WARNING/

# create a quick access link to lines in the report containing 'INFO'
info /INFO/

# each line containing 'BUILD' represents the start of a section for grouping errors and warnings found after the line.
# also creates a quick access link.
start /BUILD/",
}

file { '/etc/motd':
  content => "Welcome to your NEW Vagrant-built virtual machine!
              Managed by Puppet.\n"
}

include jenkins
include git
include drush
include imagemagick
class { 'apache':
  notify => [
    exec['clean_urls_for_drupal'],
    exec['allow_jenkins_virtual_hosts'],
  ],
}

file { "/var/lib/jenkins/conf.d":
  ensure => "directory",
}

# make some changes to /etc/httpd/conf/httpd.conf
exec { "clean_urls_for_drupal":
  command => "/bin/sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf; sudo apachectl restart",
}

# /etc/httpd/conf.d/*.conf gets deleted on every provision,
# so we put our virtual hosts elsewhere, specifically at
# /var/lib/jenkins/conf.d/*.conf. I could not get the conditional to
# work with exec, so I'm including the condition (via ||) directly
# in the command. This command adds the line only if it does not already
# exist.
exec { "allow_jenkins_virtual_hosts":
  command => '/bin/grep "Include \"\/var\/lib\/jenkins\/conf\.d\/\*.conf\"" /etc/httpd/conf/httpd.conf || /bin/echo "Include \"/var/lib/jenkins/conf.d/*.conf\"" >> /etc/httpd/conf/httpd.conf; sudo apachectl restart',
}

php::ini { '/etc/php.ini':
  display_errors => 'On',
  memory_limit   => '256M',
}
include php::cli
# see https://drupal.org/node/881098 for xml
php::module { [ 'mbstring', 'apc', 'pdo', 'mysql', 'gd', 'xml' ]: }
class { 'php::mod_php5': inifile => '/etc/php.ini' }

# See https://ask.puppetlabs.com/question/3516
# Specifying a password here causes permissions problems
# with PHP.
# See README.md on how to change the password
class { '::mysql::server':
}

# don't use a firewall, see http://stackoverflow.com/questions/5984217
service { iptables: ensure => stopped }

# Install git and dependencies, see
# https://github.com/jenkinsci/puppet-jenkins/issues/78
jenkins::plugin { 'git': }
# plot seems to be the best way to generate generic graphs
# see http://jenkinsrecip.es/add-custom-graphs-to-a-jenkins-ci-job/
jenkins::plugin { 'plot': }
jenkins::plugin { 'log-parser': }
jenkins::plugin { 'ssh-credentials': }
jenkins::plugin { 'scm-api': }
jenkins::plugin { 'credentials': }
jenkins::plugin { 'multiple-scms': }
jenkins::plugin { 'parameterized-trigger': }
jenkins::plugin { 'git-client': }
