OctopusCI
=========

OctopusCI is fresh new take on a continuous integration server centralized
around the concept of getting the same great CI benefits when using a
multi-branch workflow.

How's it Different?
-------------------

The impetus that brought OctopusCI into being was simply the lack of CI servers
that cleanly supported a software development workflow based on multiple
branches. Secondarily, it was the excessive amount of effort necessary to get a
basic CI server up and running.

Octopsuci fills this gap by providing intelligent multi-branch queueing
and multi-server job distribution. Beyond that it provides a
solid continous integration server that is trivial to get setup and running. A number
of the concepts used in OctopusCI are pulled from
[Continuous Delivery](http://continuousdelivery.com/),
[Continuous Integration](http://martinfowler.com/articles/continuousIntegration.html)
as well as Scott Chacon's post on the 
[GitHub Flow](http://scottchacon.com/2011/08/31/github-flow.html).

The following is a listing of a number of some of its more significant features.

### Dynamic Multi-Branch Triggering

OctopusCI detects branch creation/modification and dynamically generates a build for
that branch based on the project the pushed branch belongs to. Most existing CI servers
that I have used force you to manually define jobs for each branch you would like it to
manage.

### Multi-Server Job Distribution

OctopusCI allows you to configure it to run "remote jobs" on numerous servers and it
keeps track of which servers are currently busy as well as handing new jobs to the
correct servers as they become available. This is extremely valuable if you are
interested in running automated acceptance tests that take a long time to run such
as Selenium/Cucumber & Capybara Tests.

### Intelligent Multi-Branch Queueing

OctopusCI intelligently manages its job queue by by simply updating any pending jobs with
the newly pushed branch data. This means that at any given point in time there is only
ever one pending job for each branch. When, a code push comes into OctopusCI it
first looks to see if there is already a pending job for the branch that was pushed. If
there is, it simply updates the jobs associated branch data. If there is not already a
pending job then it queues a new job for that branch.

### GitHub Integration ###

OctopusCI was designed specifically to integrate cleanly with GitHub's push notifications
system. At some point in the future OctopusCI may support more than just GitHub but for
the time being GitHub is our primary focus.

Install Guide
-------------

### Install Dependencies ###

OctopusCI has one major dependency at the moment, [Redis](http://redis.io/).
[Redis](http://redis.io/) needs to be installed and configured to startup appropriately
on the box you plan to run OctopusCI on.

On Debian/Ubuntu machines this is to my knowledge as easy as `apt-get install redis-server`.

On Mac OS X machines this can easly be installed via [brew](http://mxcl.github.com/homebrew/)
using `brew install redis`. Follow the on screen instructions to configure it to auto
startup when you boot up as well as simply how to run the server manually.

### Gem & Init Skel ###

    $ gem install octopusci
    $ sudo octopusci-skel

The `octopusci-skel` command will make sure the `/etc/octopusci` path exists and its
underlying structure. It will also create a default example `/etc/ocotpusci/config.yml`
if one is not found.

### Update Example Config ###

Now that the `/etc/octopusci/config.yml` example config has been created for you it is
time to go check it out and update some of the values in it.

TODO: Fill this out with details on the config, required fields, optional fields, etc.

### Jobs ###

Add any jobs you would like to the `/etc/octopusci/jobs` directory as .rb files
and OctopusCI will load them appropriately when started.

### Web Interface ###

Figure out what directory the gem is installed in by running the following
command and stripping off the `lib/octopusci.rb` at the end.

    gem which octopusci

Once you have the path we can use that path to setup Passenger with Apache
or something else like nginx.

Apache virtual host example

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

The above will give us the web OctopusCI web interface.

If you are developing you can simply start this up by running
`rackup -p whatever_port` while inside the octopusci directory where the
`config.ru` file exists.

I recommend you setup the second half of OctopusCI (`octopusci-tentacles`) with
God or some other monitoring system. However, for development you can simply
run `octopusci-tentacles` directoly as follows:

    otopusci-tentacles

Screenshots
-----------

![OctopusCI - Dashboard](https://img.skitch.com/20111005-tfxgw59mec5msnfu3pd6is3btf.jpg)

Development
-----------

If you are interested in developing OctopusCI then please checkout the [Developer Setup](http://github.com/cyphactor/octopusci/wiki/Developer-Setup) wiki page.
