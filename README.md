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
[![Dependency Status](https://gemnasium.com/badges/github.com/curationexperts/laevigata.svg)](https://gemnasium.com/github.com/curationexperts/laevigata)     
[![Coverage Status](https://coveralls.io/repos/github/curationexperts/laevigata/badge.svg?branch=master)](https://coveralls.io/github/curationexperts/laevigata?branch=master)    
[![Inline docs](http://inch-ci.org/github/curationexperts/laevigata.svg?branch=master)](http://inch-ci.org/github/curationexperts/laevigata)     
[![Stories in Ready](https://badge.waffle.io/curationexperts/laevigata.png?label=ready&title=Ready)](https://waffle.io/curationexperts/laevigata)  

</td></tr>
</table>

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

