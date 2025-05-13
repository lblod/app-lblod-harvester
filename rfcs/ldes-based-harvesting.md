---
Stage: Draft
Start Date: 2025-05-13
Release Date: Unreleased
---

# LDES based harvesting

## summary
This rfc describes how we could adapt the harvester for working based on an LDES feed published by a publication platform. For some background on the information on the LDES feed, see the [vendor pages documentation (NL)](https://lblod.github.io/pages-vendors/#/docs/publicatie-feed). The goal of harvesting through an LDES feed is to optimize the harvesting process by limiting the amount of visits necessary to get all up to date information. 


## architecture
Similar to the current setup, the entrypoints need to be manageable via a web interface. The main difference being that the entrypoint will be an LDES feed instead of the main webpage.

### existing process
The harvesting process itself will be a bit different, for comparison here's a short description of the existing process:
An entrypoint is accompanied by a cron schedule. The cron task will follow the follow process:
- a task is created to start the scraper
- the collecting step: for scheduled jobs (with only one entrypoint), the scraper retrieves previously harvester urls of publications from the database, based on available metadata from previous tasks. Overview pages are not included, and a random 10% of the existing urls are dropped to make sure we revisit pages once in a while.
- collecting step bis: the scraper starts at the entrypoint(s) in the input container and follows lblod:linkToBesluit (and other documented) links. if a link is part of the previously visited list, the page is skipped. if a page contains relevant info (a decision, notulen, agenda or decision list) the page is stored for later processing. once all links have been (recursively) followed the scrapper goes into a success stage
- importing step (badly named): a second process extracts turtle by processing rdfa in the saved pages
- filtering step: remove invalid triples, fixes some bad triples
- add uuid-step: add uuids to each resource
- diff step: compare fetched info with already existing info for a given page. results in intersect, to remove and to add files
- publish step: apply remove and adds from diff step to the database
- delta step: generate delta's based on the remove and add files


### updated process
In the updated process, a LDES client will be polling each feed continuously. Since the feeds are configurable through the frontend we need to spin up the clients dynamically. I'd propose using the existing [ldes-consumer-manager](https://github.com/redpencilio/ldes-consumer-manager) for this.

The client will insert new publications into a specific graph for each ldes client / entrypoint. A second process would have to act on those insertions. I propose a service that monitors the graphs and creates new jobs on a fixed schedule. This allows for a generic approach, mostly compatible with the existing setup. 

The service would query the graphs each 10 minutes and 
- search for any publications not linked to a job
- for those publications, create a new job, with a collecting task having all the new publications as starting points
- link the publicaiton to the new job.

Some extra intelligence my be required:
- only creating a new job if another one is not already running
- making sure jobs don't have over a given number of urls to visit

This mostly to optimize initial ingest.

### adjustments to the interface
There needs to be a new interface to manage LDES entrypoints and follow up of the ldes consumers (are they still running, when was the last insertion that kind of thing). 
