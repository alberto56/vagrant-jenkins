group { "puppet":
  ensure => "present",
}

File { owner => 0, group => 0, mode => 0644 }

file { '/etc/motd':
  content => "Welcome to your NEW Vagrant-built virtual machine!
              Managed by Puppet.\n"
}

include jenkins