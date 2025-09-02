# `app-eli-dl-harvester`

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

## Delta's and dumps

From a consumer perspective, the delta's and dumps are available similar to any other LBLOD application. Since this app generates a lot of data, we ended up with a somewhat optimized version of the delta producer. Delta's are generated using the [harvesting-generation-delta-service](https://github.com/lblod/harvesting-generation-delta-service). Dumps are generated using the [graph-dump-service](https://github.com/lblod/graph-dump-service). The sync endpoint is provided by the [delta-producer-publication-graph-maintainer](https://github.com/lblod/delta-producer-publication-graph-maintainer/).

### Delta's

Delta's are generated as part of the harvesting pipeline. All inserted/deleted triples as listed by the [harvesting-diff-service](https://github.com/lblod/harvesting-diff-service/) will get converted to delta files. These files are listed by the delta-producer-publication-graph-maintainer and that is the only thing this particular service does in this app. This endpoint is available under `/sync/besluiten/files?since=<your-timestamp>`. It returns a maximum of 1000 files.

### Dumps

Dumps are used by consumers as a snapshot to start from, this is faster than consuming all delta's. Dumps are provided by the graph-dump-service. There is a migration adding a scheduled job to create these. To disable dumps remove the scheduled job.

Dumps are registered as dcat:Dataset's. The dump can be queried on `/datasets?filter[subject]=http://data.lblod.info/datasets/delta-producer/dumps/lblod-harvester/BesluitenCacheGraphDump&filter[:has-no:next-version]=yes`.

### Authentication

By default this application requires authentication. You can generate a migration to add a user account by using [mu-cli](https://github.com/mu-semtech/mu-cli) and running the included project script.

```sh
 mu script project-scripts generate-account
```

This should generate a migration for you to add the user account.
Afterwards make sure to restart the migration service to execute the migration

```sh
docker compose restart migrations
```

If you wish to run this application without authentication, this is also possible. You'll need to make the following changes:

```diff
#config/authorization/config.ex
       %GroupSpec{
         name: "harvesting",
         useage: [:write, :read_for_write, :read],
-        access: logged_in_user(),
+        access: %AlwaysAccessible{},
```

```diff
#docker-compose.yml
  identifier:
    environment:
-      DEFAULT_MU_AUTH_ALLOWED_GROUPS_HEADER: '[{"variables":[],"name":"public"},{"variables":[],"name":"clean"}]'
+      DEFAULT_MU_AUTH_ALLOWED_GROUPS_HEADER: '[{"variables":[],"name":"public"},{"variables":[],"name":"harvesting"}, {"variables":[],"name":"clean"}]'
  frontend:
    environment
-     EMBER_AUTHENTICATION_ENABLED: "true"
+     EMBER_AUTHENTICATION_ENABLED: "false"
```

### Triggering the healing-job manually

In some cases, you might want to trigger the healing job manually.

```
drc exec delta-producer-background-jobs-initiator wget --post-data='' http://localhost/besluiten/healing-jobs
```

### Cleaning up delta related background jobs manually

Trigger the debug endpoints in [delta-producer-background-jobs-initiator](https://github.com/lblod/delta-producer-background-jobs-initiator)

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

### Hosting large dump files

You may need to update the nginx reverse proxy settings and add the following to support dump files > 1GB in size:

```
client_max_body_size 10G;
proxy_buffering off;
```

this is typically set in /data/letsencrypt/config/vhost.d/<domain.name.her>.
