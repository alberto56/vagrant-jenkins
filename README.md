    ****************************************
    * This project is no longer maintained *
    ****************************************

VAGRANT-JENKINS
===============

By [Albert Albala (alberto56)](https://drupal.org/user/245583).

*A quick, automated way to deploy a Jenkins server tuned specifically for Drupal developers; Uses puppet to configure the server; Can be used with or without vagrant to provision any server (whether or not it's a VM on your local machine). The Jenkins server then created will be able to monitor your Drupal sites' code. Please see [Dcycle project](http://dcycleproject.org) for some best practices.*

This is meant to be used with Vagrant and Virtual Box to set up a Jenkins server running on CentOS 6.x. This has been tested with Mac OS X as a host machine, but it should be possible to run this on any host system which supports Vagrant, VirtualBox and Puppet.

For an initial deployment:

 * Install *the latest version* of [VirtualBox](https://www.virtualbox.org/wiki/Downloads) on your computer (if your VM fails to boot, especially after upgrading your OS, please upgrade your copy of VirtualBox). For more information see [this issue](https://github.com/alberto56/vagrant-jenkins/issues/11).
 * Install Vagrant on your computer
 * Install Puppet on your computer

Type the following command, from the root of this directory (`vagrant-jenkins`):

    vagrant up

You might have to wait for about an hour while all the relevant files are downloaded. Once the base box is already installed, it will take less time.

Once your box is running, and assuming no other applications (including other instances of the same box code) use port 8082, you will be able to access the guest's Jenkins at the address http://localhost:8082, and the guest's webserver at http://localhost:8083. **See "Note to OS X Yosemite 10.10 users", below, if port forwarding is not working on your Yosemite machine.

For an incremental deployment (if you've already deployed a previous version of this, which you want to update):

    vagrant reload
    vagrant provision

You might need to follow further instructions on-screen.

You can then log into your box:

    vagrant ssh

Note to OS X Yosemite 10.10 users
---------------------------------

For using a vagrant box on Mac OS 10.10 Yosemite, we are using [this technique](https://www.danpurdy.co.uk/web-development/osx-yosemite-port-forwarding-for-vagrant/) which might require you to install `vagrant-triggers` on your machine:

    vagrant plugin install vagrant-triggers

Provisioning remote VMs (without Vagrant)
-----------------------------------------

Now that we have a relatively viable recipe to install Jenkins, I tried provisioning a remote VM hosted on [Digital Ocean](https://www.digitalocean.com). To do that I first created a CentOS VM (note: I only tested this with CentOS 6.4 and it is known to _not_ work on CentOS 7), and then, on it, I enabled the puppetlabs repo and installed puppet:

    sudo rpm -ivh https://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
    sudo yum install puppet

Now, I downloaded my [Vagrant-Puppet scripts](https://github.com/alberto56/vagrant-jenkins) and ran them:

    cd
    yum install git
    git clone https://github.com/alberto56/vagrant-jenkins.git
    cd ~/vagrant-jenkins/manifests/
    yum install ruby
    yum install rubygems
    gem install puppet

Now add the module path to your puppet conf:

    vi /etc/puppet/puppet.conf

And add the following line to main:

    modulepath = /root/vagrant-jenkins/manifests/modules

Now it should be possible to apply the puppet manifest:

    puppet apply --verbose ~/vagrant-jenkins/manifests/init.pp

Notes
-----

 * This is a work in progress, make sure you are familiar with [the project issue queue](https://github.com/alberto56/vagrant-jenkins/issues) to avoid frustration.

 * I can't get [SSH agent forwarding](https://github.com/alberto56/vagrant-jenkins/issues/5) to work, so for now I am creating an SSH key pair on my guest.

To do this:

    vagrant ssh # log into vagrant box
    sudo su -s /bin/bash jenkins # login as jenkins user
    ssh-keygen -t rsa -C "jenkins@example.com" # generate ssh key pair
    # press enter to all following questions
    cat ~/.ssh/id_rsa.pub # this is your public key

It is a good idea to change the MySQL root password. You can call this:

    mysqladmin -u root -p'CHANGEME' password 'princess'

In my tests the mysql root password is sometimes empty, in which case the following might work:

    mysqladmin -u root password 'princess'

If that does not work you might have to follow the instructions [here](http://www.cyberciti.biz/tips/recover-mysql-root-password.html), using `sudo` for commands which give you an access denied.

Note finally that by default Jenkins is not using a password; *you will want to change this if your machine is publicly accessible*, here is how:

Setting up a password on Jenkins
--------------------------------

At first Jenkins has no security, meaning any user can do anything even without being logged in. I have been using Jenkins for years and every time I set up a server I this (*what not to do*):

 * Go to Manage Jenkins > Global security
 * Check "Logged in users can do anything"
 * Immediately realize you don't have an account.

To get out of this mess, do the following:

    sudo vi /var/lib/jenkins/config.xml

In that file, find `<useSecurity>true</useSecurity>` and change it to `<useSecurity>false</useSecurity>`. Then type:

    service jenkins restart

Now let's do without locking you out of Jenkins:

 * Go to configureSecurity
 * Check "Enable security"
 * Check "Jenkins' own user database"
 * Check "Allow users to sign up"
 * Check "Logged in users can do anything"
 * Save
 * Click "Create an account"
 * Username: admin, password: princess
 * Go back to configureSecurity
 * Uncheck "Allow users to sign up"
 * Save
 * At this point anonymous users will _still_ be able to _see_ jobs and artefacts, but not initiate builds or change jobs. If you want anonymous users to be shown a login screen and nothing else, follow [these instructions](http://stackoverflow.com/questions/14226681).

Setting up a Drupal project
---------------------------

To set up a Drupal project on Jenkins:

Visit http://localhost:8082

If your site is accessible publicly, please make sure you have set up security correctly (at least a password!).

Set up your first job (Freestyle software project), make sure it can connect via SSH to the git repo (If you are having trouble connecting Jenkins and Git, [read this blog post](http://dcycleproject.org/blog/51)), and make sure your MySQL root password is changed.

Now run your job, and visit the console output.

Note the workspace; it will be something like:

    /var/lib/jenkins/jobs/myjob/workspace

Now, in the command line, log in as the jenkins user (`sudo su -s /bin/bash jenkins`) and `cd` into your workspace.

Now make sure sites/default/default.settings.php exists (you might have removed it for security reasons), create your database and install Drupal:

    echo 'create database mysite'|mysql -uroot -pprincess
    drush si --db-url=mysql://root:princess@localhost/mysite

You can now exit the jenkins user:

    exit

Make a local domain in the *guest system*'s `etc/hosts`

    sudo vi /etc/hosts

Add the following line

    127.0.0.1 mysite.jenkins

Add virtual hosts:

    sudo su
    SITE=mysite
    echo '<VirtualHost *:80>' >> /var/lib/jenkins/conf.d/$SITE.conf
    echo "     DocumentRoot /var/lib/jenkins/workspace/$SITE" >> /var/lib/jenkins/conf.d/$SITE.conf
    echo "     ServerName $SITE.jenkins" >> /var/lib/jenkins/conf.d/$SITE.conf
    echo '</VirtualHost>' >> /var/lib/jenkins/conf.d/$SITE.conf

Now restart apache on the guest

    sudo apachectl restart

On your *host machine*, make sure `/etc/hosts` is modified also:

    sudo vi /etc/hosts

Add the following line

    127.0.0.1 mysite.jenkins

Log back in as the Jenkins user, go to your workspace, and in your sites/default/settings.php, make sure the base URL is set correctly to be accessible to the VM. So your line will look like:

    $base_url = 'http://mysite.jenkins';  // NO trailing slash!

Enable Simpletest and run your test suite. If you are using a [site deployment module](http://dcycleproject.org/blog/44), and you have define your simpletests there, the following should run your tests:

    drush en simpletest -y
    drush test-run mysite_deploy

Once you get that working, you can add an "Execute shell" step to your Jenkins job via the UI. However, even if your test fails, Jenkins might still mark your job as successful, as [documented here](https://github.com/drush-ops/drush/issues/212). This is why I have included the Jenkins [Log Parser plugin](https://wiki.jenkins-ci.org/display/JENKINS/Log+Parser+Plugin) in this distribution to look for output patterns in addition to exit codes in order to determine the status of a build.

You should set it up by visiting http://localhost:8082/configure, adding a Console Output Parsing rule, with the description "Main parsing file" and the File "/tmp/logparser" (these should have been created by puppet).

Now, configure your job by adding the Console Output (build log) parsing post-build action, mark build failed as error, and save.

Note that if you need more verbose results on the command line test run, for example if tests are working on your dev machine but not on jenkins, you can run, from the command line or from the jenkins job:

    php scripts/run-tests.sh --verbose mysite_deploy

Troubleshooting
---------------

 * Please see the [issue queue](https://github.com/alberto56/vagrant-jenkins/issues) if you are having troubles, and add a new issue if you don't find what you are looking for.

Fun add-ons
-----------

Here are some things I'd like to add to puppet but haven't gotten around to yet:

 * [Phantomjs for screenshots](http://www.sameerhalai.com/blog/how-to-install-phantomjs-on-a-centos-server/), this allows your Jenkins job to take a screenshot of your website's home page as viewed by an anonymous user, and save the artifact for later use. This can be a nice visual incentive for convincing your co-workers, boss or client to adopt continuous integration.
