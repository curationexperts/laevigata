# LAEVIGATA

<table width="100%">
<tr><td>
<img alt="Rosa Laevigata image" src="app/assets/images/RosaLaevigata.jpg">
</td><td>
A repository for depositing, managing, and discovering
Electronic Theses and Dissertations (ETDs).
<a href="https://en.wikipedia.org/wiki/Rosa_laevigata"><em>Rosa Laevigata</em></a>
or cherokee rose is the <a href="https://georgia.gov/georgia-facts-and-symbols">state flower of Georgia</a>.
<br/><br/>

[![Build Status](https://travis-ci.org/curationexperts/laevigata.svg?branch=master)](https://travis-ci.org/curationexperts/laevigata)         
[![Coverage Status](https://coveralls.io/repos/github/curationexperts/laevigata/badge.svg?branch=master)](https://coveralls.io/github/curationexperts/laevigata?branch=master)    
[![Inline docs](http://inch-ci.org/github/curationexperts/laevigata.svg?branch=master)](http://inch-ci.org/github/curationexperts/laevigata)     
[![Stories in Ready](https://badge.waffle.io/curationexperts/laevigata.png?label=ready&title=Ready)](https://waffle.io/curationexperts/laevigata)  

</td></tr>
</table>

## Environment variables in production
Laevigata depends on certain environment variables being set. In development mode, these can be set via a `.env` file. You can see an example in `dotenv.sample`. See also [the dotenv project](https://github.com/bkeepers/dotenv) for more details about how this works.  In production, values are set in a file called `.env.production`. Expected values include:
* `BOX_EXPIRY_TIME_IN_MINTUTES` - minutes before box upload links will expire, defaults to 360
* `RAILS_HOST` - used to generate urls in notification emails
* `ACTION_MAILER_SMTP_ADDRESS`
* `ACTION_MAILER_PORT`
* `ACTION_MAILER_USER_NAME`
* `ACTION_MAILER_PASSWORD`
* `HONEYBADGER_API_KEY`
* `BOX_OAUTH_CLIENT_ID`
* `BOX_OAUTH_CLIENT_SECRET`
* `FITS_PATH`
* `LIBREOFFICE_PATH`
* `UPLOAD_PATH`
* `CACHE_PATH`
* `DERIVATIVES_PATH`
* `WORKING_PATH`
* `FFMPEG_PATH`
* `DATABASE_NAME`
* `DATABASE_USERNAME`
* `DATABASE_PASSWORD`
* `PROQUEST_SFTP_HOST`
* `PROQUEST_SFTP_USER`
* `PROQUEST_SFTP_PASSWORD`
* `PROQUEST_NOTIFICATION_EMAIL`
* `REGISTRAR_DATA_PATH` - the file from which to load registrar data (e.g., for graduation status and dates)

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

## Developer Setup

1. Change to your working directory for new development projects   
    `cd .`
1. Clone this repo   
    `git clone https://github.com/curationexperts/laevigata.git`
1. Change to the application directory  
    `cd laevigata`
1. Use set your ruby version to **2.3.4** and the gemset of your choice  
    eg. `rvm use --create 2.3.4@laevigata`
1. Start redis  
    `redis-server &`  
    *note:* use ` &` to start in the background, or run redis in a new terminal session  
1. Read the section on 'Database Authentication' below and decide if you want to set up your environment for database authentication.
1. Start the demo server in its own terminal session
    `bin/rails hydra:server`
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

## Local Browse Everything (Box integration)

If you want to be able to test against remote uploads, e.g., with Box, set up Browse everything
locally:

1. Go to `https://app.box.com/developers/console/newapp` and log in as yourself (this will
  be your personal developer account credentials)
1. Select 'custom application' and hit 'next'
1. Select 'Standard OAuth 2.0 (User Authentication)' and hit 'next'
1. Give your app a unique name (e.g., "laevigata-bess") and it will give you a url like:
```
curl https://api.box.com/2.0/folders/0 -H \
"Authorization: Bearer lCuEl1KbmQzIQut6HVFR3IlZ4TkAaCMK"
```
1. Go to `https://app.box.com/developers/console`
1. Click on your app name, and then on the 'Configuration' tab on the left.
1. In a box labeled OAuth 2.0 Credentials you will see your OAuth credentials. You'll need these.
1. Set the `OAuth 2.0 Redirect URI` value to `http://localhost:3000` (or where ever you run
  your local development instance)
1. Save changes
1. Follow these instructions: https://github.com/samvera/browse-everything/wiki/Configuring-browse-everything
  1. `rails g browse_everything:config`
  2. copy the `client_id` and `client_secret` from box into your newly created `config/browse_everything_providers.yml` file and uncomment the `box` section
  3. The generator will try to add the BrowseEverything mount to your `config/routes.rb` file.
  This already exists in Laevigata, so remove the line it added.
1. Save everything and restart your rails server and you should be good to go!
