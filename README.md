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


### Setting up the delta-producers related services

To make sure the app can share data, producers need to be set up. There is an intial sync, that is potentially very expensive, and must be started manually

#### producers besluiten

1. make sure the app is up and running, the migrations have run
2. in docker-compose.override.yml, make sure the following configuration is provided:
```
  delta-producer-background-jobs-initiator-besluiten:
    environment:
      START_INITIAL_SYNC: 'true'
```
3. `drc up -d delta-producer-background-jobs-initiator-besluiten`
4. You can follow the status of the job, through the dashboard

### Authentication

This app allows you to both add authentication fields to the job & scheduled-jobs request as protect the app from unauthorized access via both the frontend app and api. To allow authentication you need to add an environment variable to the frontend-harvester-self-service service and update the mu-auth config.

#### Frontend service

Add the `EMBER_AUTHENICATION_ENABLED` environment variable to the frontend service and set it to TRUE

```yaml
frontend:
    image: lblod/frontend-harvesting-self-service:1.9.2
    environment:
      EMBER_AUTHENICATION_ENABLED: 'true'
    volumes:
      - ./config/frontend:/config
    labels:
      - "logging=true"
    restart: always
    logging: *default-loggingEMBER_AUTHENICATION_ENABLED: 'true'
```

#### mu-auth
Add the following function to the config:

``` elixir
defmodule Acl.UserGroups.Config do
  ...
  defp logged_in_user() do
    %AccessByQuery{
      vars: [],
      query: "PREFIX session: <http://mu.semte.ch/vocabularies/session/>
              SELECT DISTINCT ?account WHERE {
                  <SESSION_ID> session:account ?account.
        }"
      }
  end
  ...
```

Set the access function of the harvesting group to the logged_in_user() function:

```elixir
  ...
  def user_groups do
    [
      # Harvesting
      %GroupSpec{
        name: "harvesting",
        useage: [:write, :read_for_write, :read],
        access: logged_in_user(),
        graphs: [ %GraphSpec{
          ...
```

Note: make sure you are running a frontend-harvesting-self-service version that has the AUTHENTICATION_ENABLED feature flag

At last you will need to remove the `DEFAULT_MU_AUTH_ALLOWED_GROUPS_HEADER` & `DEFAULT_ACCESS_CONTROL_ALLOW_ORIGIN_HEADER` 
variables from the identifier service.


##### Additional notes

###### Performance
- The default virtuoso settings might be too weak if you need to ingest the production data. Hence, there is better config, you can take over in your `docker-compose.override.yml`
```
  virtuoso:
    volumes:
      - ./data/db:/data
      - ./config/virtuoso/virtuoso-production.ini:/data/virtuoso.ini
      - ./config/virtuoso/:/opt/virtuoso-scripts
```
###### delta-producer-report-generator
Not all required parameters are provided, since deploy specific, see [report-generator](https://github.com/lblod/delta-producer-report-generator)
###### deliver-email-service
Should have credentials provided, see [deliver-email-service](https://github.com/redpencilio/deliver-email-service)
