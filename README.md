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
1. Use set your ruby version to **2.4.2** and the gemset of your choice
    eg. `rvm use --create 2.4.2@laevigata`
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
    `bin/rails hydra:server`
1. Start the webpack dev server
   `bin/webpack-dev-server`
1. Run the first time setup script
    `bin/setup`
1. Run the test suite
    `bin/rails ci`

## Database Authentication

In production, we use Shibboleth exclusively for user authentication.  However, authenticating to Shibboleth from your local development environment might not be feasible.  Instead, you'll want to set up local database authentication.

To set your dev environment for database authentication, you need to set this environment variable:

`export LAEVIGATA_DATABASE_AUTH=true`

## User and workflow setup

Each Emory school has its own AdminSet, which determines the approval process for that
school, and who can approve deposited ETDs. Running `rake db:seed` will create an AdminSet for each school in the schools.yml file, load the appropriate workflow, and set permissions such that any registered user can deposit. `rake db:seed` should be idempotent -- you can run it over and over again safely.

A "superuser" can manage all admin_sets, edit all ETDs, and approve submissions
everywhere. To create a new superuser, add the user's email address to the `config/emory/superusers.yml` file. Then run `rake db:seed` to reload the config. Until we get real authentication running, the password for all superusers is `123456`

Note: Do *not* run `bin/setup` except the very first time you setup the application, or if you need to wipe out everything in your development instance. It will wipe your database but leave your AdminSets in place, making a huge mess that you can't easily recover from.

## Browse Everything (Box integration)

These instructions work for setting up a key either for a server or for local
testing.

1. Go to `https://app.box.com/developers/console/newapp` and log in as yourself (this will
  be your personal developer account credentials)
1. Select 'custom application' and hit 'next'
1. Select 'Standard OAuth 2.0 (User Authentication)' and hit 'next'
1. Give your app a unique name (e.g., "laevigata-yourname" or "etd-staging-upgrade") and it will give you a url like:
```
curl https://api.box.com/2.0/folders/0 -H \
"Authorization: Bearer lCuEl1KbmQzIQut6HVFR3IlZ4TkAaCMK"
```
1. Go to `https://app.box.com/developers/console`
1. Click on your app name, and then on the 'Configuration' tab on the left.
1. In a box labeled OAuth 2.0 Credentials you will see your OAuth credentials. You'll need these.
  1. Set the `OAuth 2.0 Redirect URI` value to
  `https://SERVER_NAME/auth/box/` (with the slash at the end) Or, if this is your local dev box, the value might be `http://localhost:3000/auth/box/`
  1. Set the CORS domain to `https://SERVER_NAME` (without a slash at the end) Or, if this is your local dev box, the value might be `http://localhost:3000`
1. Save changes

### Adding box credentials to a server
Add the credentials you just made to the `.env.production` file on the server where the application is running. Ideally, add them to ansible so they are maintained in
version control and the server can be re-built with these credentials in place.

### Adding box credentials locally
1. Follow these instructions: https://github.com/samvera/browse-everything/wiki/Configuring-browse-everything
  1. `rails g browse_everything:config`
  2. copy the `client_id` and `client_secret` from box into your newly created `config/browse_everything_providers.yml` file and uncomment the `box` section
  3. The generator will try to add the BrowseEverything mount to your `config/routes.rb` file.
  This already exists in Laevigata, so remove the line it added.
1. Save everything and restart your rails server and you should be good to go!

## Releasing

1. Update `.github_changelog_generator` file with the version number you're about to release
2. Generate release notes by running: `github_changelog_generator --token 7bd18e1197af58ab4e1b2d68dd5e6d52b9774f1f --max-issues 1`
3. Commit these changes to the repo, and copy-and-paste the release notes from the CHANGELOG.md file.
