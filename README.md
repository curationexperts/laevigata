[![Stories in Ready](https://badge.waffle.io/curationexperts/laevigata.png?label=ready&title=Ready)](https://waffle.io/curationexperts/laevigata)
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

</td></tr>
</table>

## Developer Setup

1) Change to your working directory for new development projects   
    `cd .`
1) Clone this repo   
    `git clone https://github.com/curationexperts/laevigata.git`
1) Change to the application directory  
    `cd laevigata`
1) Use set your ruby version to **2.3.4** and the gemset of your choice  
    eg. `rvm use --create 2.3.4@laevigata`
1) Run the first time setup script  
    `bin/setup`
1) Start redis  
    `redis-server &`  
    *note:* use ` &` to start in the background, or run redis in a new terminal session  
1) Run the test suite  
    `bin/rails ci`
1) If the tests run without error, start the demo server  
    `bin/rails hydra:server`


# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...