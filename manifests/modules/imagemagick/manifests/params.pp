class imagemagick::params {
  case $::osfamily {
    'RedHat': {
      $packages = ['ImageMagick']
    }
    default: {
      fail("${::osfamily} is not supported")
    }
  }
}
