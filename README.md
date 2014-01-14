This is meant to be used with Vagrant and Virtual Box to set up a Jenkins server running on debian.

For an initial deployment:

 * Install Vagrant on your computer
 * Install Librarian-Puppet on your computer
 * In the `manifests` directory, type `librarian-puppet install`
 * Type `vagrant up` when in the root directory (`vagrant-jenkins`)
 * You might have to wait for about an hour while all the relevant files are downloaded.

For an incremental deployment, if you've already deployed a previous version of this, and then you want to update this:

 * In the `manifests` directory, type `librarian-puppet update`
 * Type `vagrant reload` when in the root directory (`vagrant-jenkins`)
 * Type `vagrant provision` when in the root directory (`vagrant-jenkins`)
 * You might need to follow further instructions on-screen.
 