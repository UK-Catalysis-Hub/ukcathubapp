## Development
The prototype is designed using Ruby on Rails. It is intended to provide a
quick look at the possiblities for cataloguing data and publications.

* Ruby version: 3.2.2
* Rails version: 7.1.3.2

### Latest changes

At this point the app can be deployed in VM/Cloud using docker.

* Docker based deployment
  * dockerfile
  * docker-compose.yml
  * tested with nginx
  * verified sidekiq and redis working
  * using volumes for persistence of data and uploads


### Work in progress
This is the current work being done to improve the app

* Migration to Postgress

### To do
Next steps in development to get to production ready code

* Enable https
* improve logging visibility
* nginx optimisation


