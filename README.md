
# app-lblod-harvester

  <br>

## Table of content

	
* [Description](#description)
* [List of services](#list-of-services)
* [Setup](#setup)
* [Importing Data](#importing-data)
   *  [Data sources](#data-sources) 
 * [Frontend](#frontend)
   * [Technologies](#technologies) 
   *  [Usage](#usage)
   *  [Environment](#environment)
* [Debugging/logging](#debugginglogging)
* [More information](#more-information)

<br>

## Description

Based on the mu-semtech microservice architecture for the backend en Emberjs for the frontend. 

<br>

## List of Services
	

| Service  | Repository  | 
|---|---|
| identifier  | https://github.com/mu-semtech/mu-identifier  |   
| dispatcher  | https://github.com/mu-semtech/mu-dispatcher  |  
| database  | https://github.com/mu-semtech/mu-authorization  | 
| virtuoso  | https://github.com/tenforce/docker-virtuoso  | 
| migrations | https://github.com/mu-semtech/mu-migrations-service |
| cache | https://github.com/mu-semtech/mu-cache |
| delta-notifier | https://github.com/mu-semtech/delta-notifier |
| file | https://github.com/mu-semtech/file-service |
| harvesting-download-url | https://hub.docker.com/r/lblod/download-url-service  |
| harvesting-initiation  | https://github.com/lblod/harvesting-initiation-service |
| harvest-collector | https://github.com/lblod/harvest-collector-service |
| harvesting-import | https://github.com/lblod/harvesting-import-service |
| harvesting-validator | https://github.com/lblod/harvesting-validator |
| resource | https://github.com/mu-semtech/mu-cl-resources |


<br>

## Setup


#### Clone this repository
``` 
git clone https://github.com/lblod/app-lblod-harvester.git
```
  

#### Move into the directory
```
cd app-lblod-harvester
```
  

#### Start the system
```
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

<small>It takes a minute before everything is up and running. In case there is an error the first time you launch, just stopping and relaunching docker compose should resolve any issues. </small>

#### Visit the App!

Simply visit http://localhost:80 and you will redirected to the yasgui sparql interface. More info about the frontend in the [frontend section](#frontend) below.
  
  <br>

## Frontend

### Technologies

The frontend is what the user actually interacts with. With the use of our addons you are presented with a sparql interface and when visiting different routes with the corresponding , rdf-friendly, data. 
It is build on top of the [Ember.js](https://emberjs.com/) framework. And server side rendered by [Fastboot](#https://ember-fastboot.com/)



