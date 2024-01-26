export default [
  {
    match: {
      subject: {},
    },
    callback: {
      url: "http://resource/.mu/delta",
      method: "POST",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 250,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
      object: {
        type: "uri",
        value: "http://redpencil.data.gift/id/concept/JobStatus/scheduled",
      },
    },
    callback: {
      method: "POST",
      url: "http://harvest_singleton-job/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
      object: {
        type: "uri",
        value: "http://redpencil.data.gift/id/concept/JobStatus/scheduled",
      },
    },
    callback: {
      method: "POST",
      url: "http://harvest_scraper/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
      object: {
        type: "uri",
        value: "http://redpencil.data.gift/id/concept/JobStatus/scheduled",
      },
    },
    callback: {
      method: "POST",
      url: "http://harvest_import/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
      object: {
        type: "uri",
        value: "http://redpencil.data.gift/id/concept/JobStatus/scheduled",
      },
    },
    callback: {
      method: "POST",
      url: "http://harvest_cleanup/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  // {
  //   match: {
  //     predicate: {
  //       type: 'uri',
  //       value: 'http://www.w3.org/ns/adms#status',
  //     },
  //     object: {
  //       type: 'uri',
  //       value: 'http://redpencil.data.gift/id/concept/JobStatus/scheduled',
  //     },
  //   },
  //   callback: {
  //     method: 'POST',
  //     url: 'http://harvest_compression/delta',
  //   },
  //   options: {
  //     resourceFormat: 'v0.0.1',
  //     gracePeriod: 1000,
  //     ignoreFromSelf: true,
  //   },
  // },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
      object: {
        type: "uri",
        value: "http://redpencil.data.gift/id/concept/JobStatus/scheduled",
      },
    },
    callback: {
      method: "POST",
      url: "http://harvest_validate/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
      object: {
        type: "uri",
        value: "http://redpencil.data.gift/id/concept/JobStatus/scheduled",
      },
    },
    callback: {
      method: "POST",
      url: "http://harvest_gen_delta/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
      object: {
        type: "uri",
        value: "http://redpencil.data.gift/id/concept/JobStatus/scheduled",
      },
    },
    callback: {
      method: "POST",
      url: "http://harvest_diff/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
      object: {
        type: "uri",
        value: "http://redpencil.data.gift/id/concept/JobStatus/scheduled",
      },
    },
    callback: {
      method: "POST",
      url: "http://harvest_check-url/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
      object: {
        type: "uri",
        value: "http://redpencil.data.gift/id/concept/JobStatus/scheduled",
      },
    },
    callback: {
      method: "POST",
      url: "http://harvest_sameas/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
    },
    callback: {
      method: "POST",
      url: "http://job-controller/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
      },
      object: {
        type: "uri",
        value: "http://vocab.deri.ie/cogs#ScheduledJob",
      },
    },
    callback: {
      method: "POST",
      url: "http://scheduled-job-controller/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      //Allow more time (10s) for the frontend to have saved everything. If the
      //scheduled-job exists before its tasks and authentication configuration,
      //then the scheduled job service tries to query that data before it is
      //written to the triplestore, failing to encrypt the secrets for the
      //scheduled task.
      gracePeriod: 10000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
      },
      object: {
        type: "uri",
        value: "http://redpencil.data.gift/vocabularies/deltas/Error",
      },
    },
    callback: {
      url: "http://delta-producer-report-generator/delta",
      method: "POST",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
    },
    callback: {
      url: "http://delta-producer-report-generator/delta",
      method: "POST",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      graph: {
        type: "uri",
        value: "http://mu.semte.ch/graphs/public",
      },
    },
    callback: {
      url: "http://delta-producer-publication-graph-maintainer/besluiten/delta",
      method: "POST",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      graph: {
        type: "uri",
        value: "http://mu.semte.ch/graphs/harvesting",
      },
    },
    callback: {
      url: "http://delta-producer-publication-graph-maintainer/besluiten/delta",
      method: "POST",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/ns/adms#status",
      },
      object: {
        type: "uri",
        value: "http://redpencil.data.gift/id/concept/JobStatus/scheduled",
      },
    },
    callback: {
      url: "http://delta-producer-dump-file-publisher/delta",
      method: "POST",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://schema.org/repeatFrequency",
      },
    },
    callback: {
      method: "POST",
      url: "http://scheduled-job-controller/delta",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
  {
    match: {
      predicate: {
        type: "uri",
        value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
      },
      object: {
        type: "uri",
        value: "http://open-services.net/ns/core#Error",
      },
    },
    callback: {
      url: "http://error-alert/delta",
      method: "POST",
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true,
    },
  },
];
