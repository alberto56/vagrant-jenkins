# == Define: drush::exec
#
# Execute a single Drush command.
#
# === Parameters
#
# [*command*]
#   Specify a Drush command to execute. Defaults to the title of this defined
#   resource.
#
# [*root_directory*]
#   Specify a path in which Drush will execute the command. Defaults to
#   "/var/www/html".
#
# [*uri*]
#   Specify a URI of the Drupal site to use. Defaults to "default".
#
# === Examples
#
# Provide some examples on how to use this type:
#
#   drush::exec { 'drush-views-download':
#     command        => 'pm-download views',
#     root_directory => '/var/www/html',
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
define drush::exec(
  $command        = $title,
  $root_directory = '/var/www/html',
  $uri            = nil,
  $force          = false,
  $options        = [],
) {

  include drush

  $root_option = "--root=${root_directory}"

  $force_option = $force ? {
    true  => '--yes',
    false => '',
  }

  if $uri != nil {
    $uri_option = "--uri=${uri}"
  } else {
    $uri_option = ''
  }

  $additional_options = join($options, ' ')

  exec { "drush-${title}":
    command => "drush ${command} ${root_option} ${uri_option} ${force_option} ${additional_options}",
    path    => [ '/bin', '/usr/bin' ],
    require => Pear::Package['drush']
  }

}
