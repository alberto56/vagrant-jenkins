class { 'drush':
  version => '5.8.0',
}

drush::exec { 'drush-drupal-download':
  command        => 'pm-download drupal',
  root_directory => '/tmp',
}
