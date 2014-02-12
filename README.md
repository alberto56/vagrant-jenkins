This is meant to be used with Vagrant and Virtual Box to set up a Jenkins server running on CentOS 6.x.

For an initial deployment:

 * Install Vagrant on your computer
 * Install Puppet on your computer
 * Install Librarian-Puppet on your computer

Type the following commands, from the root of this directory (`vagrant-jenkins`):

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

Then, run the following commands:

    mkdir -p /etc/puppet/manifests
    cd /etc/puppet/manifests
    git clone https://github.com/alberto56/vagrant-jenkins.git
    cd vagrant-jenkins/manifests
    librarian-puppet install

Then, for an initial or incremental deployment, type
    
    puppet apply --verbose /etc/puppet/manifests/vagrant-jenkins/manifests/init.pp

Notes
-----

 * This is a work in progress, make sure you are familiar with [the project issue queue](https://github.com/alberto56/vagrant-jenkins/issues) to avoid frustration.

 * I can't get [SSH agent forwarding](https://github.com/alberto56/vagrant-jenkins/issues/5) to work, so for now I am creating an SSH key pair on my machine.

 * If you are having trouble connecting Jenkins and Git, [read this blog post](http://dcycleproject.org/blog/51).

It is a good idea to change the MySQL root password. You can call this:

    mysqladmin -u root -p'CHANGEME' password 'princess'

If that does not work you might have to follow the instructions [here](http://www.cyberciti.biz/tips/recover-mysql-root-password.html), using `sudo` for commands which give you an access denied.

Setting up a Drupal project
---------------------------

Visit http://localhost:8082

If your site is accessible publicly, please make sure you have set up security correctly (at least a password!).

Set up your first job, make sure it can connect via SSH to the git repo (see above), and make sure your MySQL root password is changed.

Now run your job, and visit the console output.

Note the workspace; it will be something like:

    /var/lib/jenkins/jobs/myjob/workspace

Now, in the command line, log in as the jenkins user (`sudo su -s /bin/bash jenkins`) and `cd` into your workspace.

Create your database and install Drupal:

    echo 'create database mysite'|mysql -uroot -pprincess
    drush si --db-url=mysql://root:princess@localhost/mysite

Make a local domain to the *guest system* in `etc/hosts`

    sudo vi /etc/hosts

Add the following line

    127.0.0.1 mysite.jenkins

Add virtual hosts:

    sudo vi /etc/httpd/conf.d/mysite.conf

Add the following:

    <VirtualHost *:80>
         DocumentRoot /var/lib/jenkins/jobs/myjob/workspace
         ServerName mysite.jenkins
    </VirtualHost>

(For a reason I don't understand, this configuration gets erased sometimes when re-provisioning from puppet).

Finally, for clean URLs to work, I want to eventually automate this in puppet but for now could not figure out how. I apply this manually:

    sudo vi /etc/httpd/conf/httpd.conf

And, then, change `AllowOverride None` to `AllowOverride All`.

Now restart apache on the guest

    sudo apachectl restart

On your *host machine*, make sure `/etc/hosts` is modified also:

    sudo vi /etc/hosts

Add the following line

    127.0.0.1 mysite.jenkins

In your sites/default/settings.php, make sure the base URL is set correctly to be accessible to the VM. So your line will look like:

    $base_url = 'http://mysite.jenkins';  // NO trailing slash!

Enable Simpletest and run your test suite. If you are using a [site deployment module](http://dcycleproject.org/blog/44), and you have define your simpletests there, the following should run your tests:

    drush en simpletest -y
    drush test-run mysite_deploy

Once you get that working, you can add an "Execute shell" step to your Jenkins job via the UI. However, even if your test fails, Jenkins might not pick up on it, as [documented here](https://github.com/drush-ops/drush/issues/212). I have included the Jenkins [Log Parser plugin](https://wiki.jenkins-ci.org/display/JENKINS/Log+Parser+Plugin) in this distribution. You should set it up by visiting http://localhost:8082/configure, adding a Console Output Parsing rule, with the description "Main parsing file" and the File "/tmp/logparser".