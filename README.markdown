Octopusci
=========

Octopusci is fresh new take on a continuous integration server centralized
around the concept of getting the same great CI benefits when using multi-branch
workflow.

How's it Different?
-------------------

The impetus that brought Octopusci into being was simply the lack of CI servers
that cleanly supported a software development workflow based on multiple
branches. Secondarily, it was the excessive amount of effort necessary to get a
basic CI server up and running.

Octopsuci fills this gap by providing intelligent multi-branch queueing
and multi-server job distribution. Beyond that it provides a
solid continous integration server that is trivial to get setup and running. A number
of the concepts used in Octopusci are pulled from
[Continuous Delivery](http://continuousdelivery.com/),
[Continuous Integration](http://martinfowler.com/articles/continuousIntegration.html)
as well as Scott Chacon's post on the 
[GitHub Flow](http://scottchacon.com/2011/08/31/github-flow.html).

The following is a listing of a number of some of its more significant features.

### Dynamic Multi-Branch Triggering

Octopusci detects branch creation/modification and dynamically generates a build for
that branch based on the project the pushed branch belongs to. Most existing CI servers
that I have used force you to manually define jobs for each branch you would like it to
manage.

### Multi-Server Job Distribution

Octopusci allows you to configure it to run "remote jobs" on numerous servers and it
keeps track of which servers are currently busy as well as handing new jobs to the
correct servers as they become available. This is extremely valuable if you are
interested in running automated acceptance tests that take a long time to run such
as Selenium/Cucumber & Capybara Tests.

### Intelligent Multi-Branch Queueing

Octopusci intelligently manages its job queue by by simply updating any pending jobs with
the newly pushed branch data. This means that at any given point in time there is only
ever one pending job for each branch. When, a code push comes into Octopusci it
first looks to see if there is already a pending job for the branch that was pushed. If
there is, it simply updates the jobs associated branch data. If there is not already a
pending job then it queues a new job for that branch.

Quickstart
----------

I install guides

    $ gem install octopusci
    $ sudo octopusci-skel


The purpose of this project is provide a simple CI server that will work with
GitHub Post-Receive hook. It is also specifically designed to handle multiple
build/job queues for each branch.

This would basically allow you to every time code is pushed to the central
repository enqueue a build/job for the specific branch. That way if you
have topic branches that are being pushed to the central repository along
side the mainline branch they will get queue properly as well.

My idea for implementation at this point is that if I can detect the branch
from the GitHub Post-Receive hook then I can identify branch. If I can
identify branch then I can maintain individual queues for each branch.

Then the execution would look at config values for predefined branches and
priorities for order of running them so that the mainline branch running its
jobs could take precedence over non specified topic branches.

Install redis and get it starting up appropriately

gem install octopusci
sudo octopusci-skel
octopusci-db-migrate

Then update the /etc/octopusci/config.yml appropriately.

Add any jobs you would like to the /etc/octopusci/jobs directory as rb files
and octopusci will load them appropriately when started.

Figure out what directory the gem is installed in by running the following
command and stripping off the lib/octopusci.rb at the end.

gem which octopusci

Once you have the path we can use that path to setup Passenger with Apache
or something else like nginx as well as setup the database. Note: You will
need to setup a database user and a database for octopusci. The settings for
these should be stored in /etc/octopusci/config.yml.

rake -f /path/of/octpusci/we/got/before/Rakefile db:migrate

<VirtualHost *:80>
  ServerName octopusci.example.com
  PassengerAppRoot /path/of/octpusci/we/got/before
  DocumentRoot /path/of/octpusci/we/got/before/lib/octopusci/server/public
  <Directory /path/of/octpusci/we/got/before/lib/octopusci/server/public>
    Order allow,deny
    Allow from all
    AllowOverride all
    Options -MultiViews
  </Directory>
</VirtualHost>

The above will give us the web Octopusci web interface.

If you are developing you can simply start this up by running
rackup -p whatever_port while inside the octopusci directory where the
config.ru file exists.

I recommend you setup the second half of Octopusci (octopusci-tentacles) with
God or some other monitoring system. However, for development you can simply
run octopusci-tentacles directoly as follows:

otopusci-tentacles

Screenshots
-----------

![Octopusci - Dashboard](https://img.skitch.com/20111005-tfxgw59mec5msnfu3pd6is3btf.jpg)
