# `app-lblod-harvester`

Mu-semtech stack for harvesting and processing Decisions from external sources.
For the harvesting of Worship Decisions with focus on authentication, see
[`app-lblod-harvester-worship`](https://github.com/lblod/app-lblod-harvester-worship).

## List of Services

See the `docker-compose.yml` file.

## Setup and startup

To start this stack, clone this repository and start it using `docker compose`
using the following example snippet.

```bash
git clone git@github.com:lblod/app-lblod-harvester.git
cd app-lblod-harvester
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

It can take a while before everything is up and running. In case there is an
error the first time you launch, just stopping and relaunching `docker compose`
should resolve any issues:

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml stop
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

After starting, you might still have to wait for all the services to boot up,
and migrations to finish running. You can check this by inspecting the Docker
logs and wait for things to settle down. Once the stack is up and running
without errors you can visit the frontend in a browser on
`http://localhost:80`.

## Setting up the delta-producers

To make sure the app can share data, producers need to be set up. There is an
intial sync, that is potentially very expensive, and must be started manually.

### Producers besluiten

1. Make sure the app is up and running, and the migrations have run.
2. In a `docker-compose.override.yml` file, make sure the following
   configuration is provided:

     ```yaml
     delta-producer-background-jobs-initiator-besluiten:
       environment:
         START_INITIAL_SYNC: 'true'
     ```

3. Restart the service: `drc up -d
   delta-producer-background-jobs-initiator-besluiten`
4. You can follow the status of the job, through the dashboard frontend.

## Additional notes

### Performance

The default Virtuoso settings might be too weak if you need to ingest the
production data. There is a better config for this that you can use in your
`docker-compose.override.yml`

```yaml
virtuoso:
  volumes:
    - ./data/db:/data
    - ./config/virtuoso/virtuoso-production.ini:/data/virtuoso.ini
    - ./config/virtuoso/:/opt/virtuoso-scripts
```

### `delta-producer-report-generator`

Not all required parameters are provided, since these are deploy specific, see
[the delta-producer-report-generator
repository](https://github.com/lblod/delta-producer-report-generator).

### `deliver-email-service`

Should have credentials provided, see [the deliver-email-service
repository](https://github.com/redpencilio/deliver-email-service).
