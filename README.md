# LAEVIGATA

<table width="100%">
<tr><td>
<img alt="Rosa Laevigata image" src="app/assets/images/RosaLaevigata.jpg">
</td><td>
A repository for depositing, managing, and discovering
Emory Theses and Dissertations (ETDs).
<a href="https://en.wikipedia.org/wiki/Rosa_laevigata"><em>Rosa Laevigata</em></a>
or cherokee rose is the <a href="https://georgia.gov/georgia-facts-and-symbols">state flower of Georgia</a>.
<br/><br/>

[![CircleCI](https://circleci.com/gh/curationexperts/laevigata/tree/main.svg?style=svg)](https://circleci.com/gh/curationexperts/laevigata/tree/main)
[![Coverage Status](https://coveralls.io/repos/github/curationexperts/laevigata/badge.svg?branch=main)](https://coveralls.io/github/curationexperts/laevigata?branch=main)
[![Inline docs](http://inch-ci.org/github/curationexperts/laevigata.svg?branch=main)](http://inch-ci.org/github/curationexperts/laevigata)

</td></tr>
</table>


## Developer Setup

1. Change to your working directory for new development projects  
    `cd .`
2. Clone this repo  
    `git clone https://github.com/curationexperts/laevigata.git`
3. Change to the application directory  
    `cd laevigata`
4. Set your development environment ruby version to **2.7.4**  
    eg. `rvm use --create 2.7.4@laevigata` or `rbenv local 2.7.4`
5. Install gem dependencies  
    `bundle install`
6. Ensure you have **yarn** installed  
   `brew install yarn` or `npm install -g yarn`
7. Install yarn dependencies  
    `yarn install`
    
    *NOTE* node-sass is particular about node versions, see their [version support policy](https://github.com/sass/node-sass#node-version-support-policy) if you're having difficulty
8. Install ClamAV  
    This is required if you want to work with file uploads in your development environment.
    See: [Installing ClamAV](https://www.clamav.net/documents/installing-clamav) for instructions.
9. Start redis  
    `redis-server &`
    *note:* use ` &` to start in the background, or run redis in a new terminal session
10. Setup environment variables for your development environment  
     `cp dotenv.sample .env.development`,
     see the [dotenv sample file](dotenv.sample) for environment variables you may need to set in your development environment.  
11. Start the Rails server along with development instances of Solr & Fedora  
     NOTE: you'll usually run this in its own terminal session  
     `bundle exec rake hydra:server`
12. Start the webpack dev server  
    `bin/webpack-dev-server`
13. Run the first time setup script  
    `bin/setup`  
    Note: Do *not* run `bin/setup` except the very first time you setup the application, 
    or if you need to wipe out everything in your development instance. It will wipe your 
    database but leave your AdminSets in place, making a huge mess that you can't easily recover from.
14. Start up the test environment  
     ```
     solr_wrapper --config config/solr_wrapper_test.yml  
     fcrepo_wrapper --config config/fcrepo_wrapper_test.yml
     ```  
     and run the rspec test suite  
     `bundle exec rspec`
15. Run the Vue javascript tests  
     `yarn test`. In order to include coverage, run `yarn test --coverage`.

## Database Authentication

In production, we use Shibboleth exclusively for user authentication. 
However, authenticating to Shibboleth from your local development environment is not feasible. 
Instead, you'll want to set up local database authentication.

To set your dev environment for database authentication, you need to set this environment variable:  
`export LAEVIGATA_DATABASE_AUTH=true`

## User and workflow setup

Each Emory school, and each Rollins department, has its own AdminSet, which manages the approval
workflow and approvers for that department or school.  To bootstrap a new environment run
```
rake emory:update_roles
```
This will create an AdminSet for each school in the schools.yml file, load the appropriate workflow,
and set permissions such that any registered user can deposit. The `emory:update_roles` task is idempotent 
-- you can run it over and over again safely.

If you have a favorite username you like to use to login to the UI in your development environments, create 
that user in your local development environment and add it to the database section in 
your local copy of [config/emory/superusers.yml](https://github.com/curationexperts/laevigata/blob/main/config/emory/superusers.yml)

A "superuser" can manage all admin_sets, edit all ETDs, and approve submissions
for any school or department.

To update approvers or superusers in your development environment, update the appropriate file in [config/emory/](https://github.com/curationexperts/laevigata/blob/main/config/emory/)
and run 'rake emory:update_roles'.  Refer to the wiki for instruction on how to update approvers 
and superusers in production.

## Smoke Tests
Some long runnng tests and/or tests that test external systems have been filtered out of general runs of 
the test suite.  Tests can be marked with `smoke_test: true` in the test definition to add them to this group.
In order to run these tests, either run the test individually by name or line number or run the suite with
the SMOKE_TEST environment variable set - e.g.
```
SMOKE_TEST=true bundle exec rspec
```

## Cron jobs in production

There are certain cron jobs that are expected to run in production. These include embargo expiration,
proquest notifications, etd report csv generation and others. We use the `whenever` gem to manage these.

If you need to make changes to the scheduled jobs, please update `config/schedule.rb` and
the new crontab should be installed via capistrano when the code is deployed.

Please note that in order to run as expected, the PATH must be defined: run `crontab -e` as the `deploy` user and
ensure these lines are at the top of your cron file:
```
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
```

**Please ensure that any scheduled jobs write to the rails log file so we can track whether they are
running as expected.**

## Suppressing email for bouncing addresses

If an email address is bouncing, or if someone prefers not to receive email notifications,
add the email address to the list in `config/emory/do_not_send.yml`

## Copying embargo notification emails to a staff member

To send a copy of all notification expiration emails to a staff member, add that
person's uid to an environment variable called EMBARGO_NOTIFICATION_CC in the
.env.production file on the production server (other servers are configured not to
  send email).
