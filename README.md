This is meant to be used with Vagrant and Virtual Box to set up a Jenkins server running on CentOS 6.x.

For an initial deployment:

 * Install Vagrant on your computer
 * Install Librarian-Puppet on your computer
 * Type the following commands, from the root of this directory (`vagrant-jenkins`):


    cd manifests
    librarian-puppet install
    cd ..
    vagrant up

You might have to wait for about an hour while all the relevant files are downloaded. Once the base box is already installed, it will take less time.

Once your box is running, and assuming no other applications (including other instances of the same box code) use port 8082, you will be able to access Jenkins at the address http://localhost:8082

For an incremental deployment, if you've already deployed a previous version of this, and then you want to update this:

    cd manifests
    librarian-puppet update
    cd ..
    vagrant reload
    vagrant provision

You might need to follow further instructions on-screen.

Note that you can also use this project without vagrant, with puppet in a client-server or standalone architecture:

 * Install CentOS 6.x on a server.
 * Install Puppet and Librarian-Puppet
 * Run the following commands:


    mkdir -p /etc/puppet/manifests
    cd /etc/puppet/manifests
    git clone https://github.com/alberto56/vagrant-jenkins.git
    cd vagrant-jenkins/manifests
    librarian-puppet install

Then, for an initial or incremental deployment, type
    
    puppet apply --verbose /etc/puppet/manifests/vagrant-jenkins/manifests/init.pp
