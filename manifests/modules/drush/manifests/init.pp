# == Class: drush
#
# Install Drush.
#
# === Parameters
#
# [*version*]
#   Specify a Drush version to install.
#
# === Examples
#
#   class { 'drush':
#     version => '5.8.0',
#   }
#
# === Authors
#
# Erik Webb <erik@erikwebb.net>
#
# === Copyright
#
# Copyright 2013 Erik Webb, unless otherwise noted.
#
class drush(
  $version = 'latest'
) {

  # Setup Drush for following tasks
  include pear

  pear::package { 'PEAR': }
  pear::package { 'Console_Table': }

  # Version numbers are supported.
  pear::package { 'drush':
    version    => $version,
    repository => 'pear.drush.org',
  }

}
