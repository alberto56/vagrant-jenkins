Puppet module for Drush
=======================

A Puppet module to install Drush and execute commands.

Basic usage
-----------

To download a single Drupal module:

    drush::exec { 'drush-views-download':
      command        => 'pm-download views',
      root_directory => '/var/www/html',
    }

Dependencies
------------

Some functionality is dependent on other modules:

- [rafaelfc/pear](http://forge.puppetlabs.com/rafaelfc/pear)

