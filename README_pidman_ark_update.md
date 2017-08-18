# Update pidman for an ark

1. Make sure that we have a new host name set up: legacy-etd.library.emory.edu 

2. Get SSL certificate for the domain

3. Run a custom python-django manage command that replaces all target uris of etd pids with a new domain

Original Example: https://etd.library.emory.edu/view/record/pid/emory:s0d70

Updated Example: https://legacy-etd.library.emory.edu/view/record/pid/emory:s0d70

## Basic functionality of the script

1. Query the database to find all legacy etd pids.

2. Loop through all of the legacy etd pids.

3. For each etd query request replace the target uri with a new base host.

4. Save each new target uri in the database.


## Script Testing

We have Pidman QA environment that works with legacy ETD QA.

For testing purposes, run the script against the QA environment to make sure it is properly working before running on production.