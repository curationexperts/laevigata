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

[![CircleCI](https://circleci.com/gh/curationexperts/laevigata/tree/master.svg?style=svg)](https://circleci.com/gh/curationexperts/laevigata/tree/master)
[![Coverage Status](https://coveralls.io/repos/github/curationexperts/laevigata/badge.svg?branch=master)](https://coveralls.io/github/curationexperts/laevigata?branch=master)
[![Inline docs](http://inch-ci.org/github/curationexperts/laevigata.svg?branch=master)](http://inch-ci.org/github/curationexperts/laevigata)

</td></tr>
</table>

## Environment variables in development

See the [dotenv sample file](dotenv.sample) for environment variables you may need to set in your development environment.

## Cron jobs in production

There are certain cron jobs that are expected to run in production. These include graduation job,
fixity audit, embargo expiration, and others. We use the `whenever` gem to manage these.
If you need to make changes to the scheduled jobs, please update `config/schedule.rb` and the new crontab should be installed via capistrano when the code is deployed.

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

## Developer Setup

1. Change to your working directory for new development projects
    `cd .`
1. Clone this repo
    `git clone https://github.com/curationexperts/laevigata.git`
1. Change to the application directory
    `cd laevigata`
1. Set your ruby version to **2.7.2** and the gemset of your choice
    eg. `rvm use --create 2.7.2@laevigata`
1. Install gem dependencies
    `bundle install`
1. Ensure you have `yarn` installed:
   `brew install yarn` or
   `npm install -g yarn`
1. Install yarn dependencies
    `yarn install`
1. Install ClamAV
    This is required if you want to work with file uploads in your development environment.
    See: [Installing ClamAV](https://www.clamav.net/documents/installing-clamav) for instructions.
1. Start redis
    `redis-server &`
    *note:* use ` &` to start in the background, or run redis in a new terminal session
1. Setup environment variables for your development environment:
    `cp dotenv.sample .env.development`,
    see the [Environment variables in development](#environment-variables-in-development) section for more details
1. Read the section on 'Database Authentication' below and decide if you want to set up your environment for database authentication.
1. Start the demo server in its own terminal session
    `bundle exec rake hydra:server`
1. Start the webpack dev server
   `bin/webpack-dev-server`
1. Run the first time setup script
    `bin/setup`
1. Start up the test environment
    `solr_wrapper --config config/solr_wrapper_test.yml`
    `fcrepo_wrapper --config config/fcrepo_wrapper_test.yml`
    and run the test suite
    `bundle exec rspec`

## Database Authentication

In production, we use Shibboleth exclusively for user authentication.  However, authenticating to Shibboleth from your local development environment might not be feasible.  Instead, you'll want to set up local database authentication.

To set your dev environment for database authentication, you need to set this environment variable:

`export LAEVIGATA_DATABASE_AUTH=true`

## User and workflow setup

Each Emory school has its own AdminSet, which determines the approval process for that
school, and who can approve deposited ETDs. Running `rake db:seed` will create an AdminSet for each school in the schools.yml file, load the appropriate workflow, and set permissions such that any registered user can deposit. `rake db:seed` should be idempotent -- you can run it over and over again safely.

A "superuser" can manage all admin_sets, edit all ETDs, and approve submissions
everywhere. To create a new superuser, add the user's email address to the `config/emory/superusers.yml` file. Then run `rake db:seed` to reload the config. When using database authentication, the password for all superusers is `123456`.

Note: Do *not* run `bin/setup` except the very first time you setup the application, or if you need to wipe out everything in your development instance. It will wipe your database but leave your AdminSets in place, making a huge mess that you can't easily recover from.

## Releasing

1. Update `.github_changelog_generator` file with the version number you're about to release
2. Generate release notes by running: `github_changelog_generator --token $YOUR_GITHUB_TOKEN --max-issues 1`
3. Commit these changes to the repo, and copy-and-paste the release notes from the CHANGELOG.md file.
