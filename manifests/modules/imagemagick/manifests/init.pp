class imagemagick {
  include ::imagemagick::params

  package {$::imagemagick::params::packages:
    ensure => installed
  }
}
