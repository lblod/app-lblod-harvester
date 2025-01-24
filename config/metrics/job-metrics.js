import promClient from 'prom-client';
import { querySudo as query } from '@lblod/mu-auth-sudo';
const jobStatusGauge = new promClient.Gauge({
  name: 'semtech_job_status_count',
  help: 'jobs per status',
  labelNames: ['status']
});
const longRunningJobsGauge = new promClient.Gauge({
  name: 'semtech_jobs_running_at_least_24_hours_count',
  help: 'count of jobs that have been busy for more than 24 hours'
});

const register = promClient.register;

const STATUS_MAP = {
  'http://redpencil.data.gift/id/concept/JobStatus/success': 'success',
  'http://redpencil.data.gift/id/concept/JobStatus/busy': 'busy',
  'http://redpencil.data.gift/id/concept/JobStatus/failed': 'failed',
  'http://redpencil.data.gift/id/concept/JobStatus/scheduled': 'scheduled',
};

const jobStatusQuery = `
PREFIX cogs: <http://vocab.deri.ie/cogs#>
PREFIX adms: <http://www.w3.org/ns/adms#>

SELECT (COUNT(?job) as ?jobs) ?status WHERE {
       ?job a cogs:Job.
        OPTIONAL { ?job adms:status ?status . }
}
GROUP BY ?status
ORDER BY ?status
`;

const longRunningJobsQuery = `
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX cogs: <http://vocab.deri.ie/cogs#>
PREFIX adms: <http://www.w3.org/ns/adms#>

SELECT (COUNT(?job) as ?jobs) WHERE {
       ?job a cogs:Job.
        ?job adms:status <http://redpencil.data.gift/id/concept/JobStatus/busy>;
             dct:created ?created.
        BIND(NOW() - "P1D"^^xsd:duration AS ?yesterday)
  FILTER(?created < ?yesterday)
}
`;

async function updateJobsPerStatusGauge() {
  const statusCounts = Object.fromEntries(
    Object.values(STATUS_MAP).map(status => [status, 0])
  );

  const response = await query(jobStatusQuery);
  if (response.results.bindings) {
    for (const binding of response.results.bindings) {
      const status = STATUS_MAP[binding.status?.value];
      const count = parseInt(binding.jobs.value);
      if (status) statusCounts[status] = count;
    }
    for (const [status, count] of Object.entries(statusCounts)) {
      jobStatusGauge.labels({status}).set(count);
    }
  }
}

async function updateLongRunningJobs() {
  const response = await query(longRunningJobsQuery);
  if (response.results.bindings) {
    const binding = response.results.bindings[0];
    const count = parseInt(binding.jobs.value);
    longRunningJobsGauge.set(count);
  }
}

export default {
  name: 'job statuses',
  cronPattern: '*/10 * * * *',
  async cronExecute() {
    await updateJobsPerStatusGauge();
    await updateLongRunningJobs();
  },
  async metrics() {
    return await register.metrics();
  }
}
