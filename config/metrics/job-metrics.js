import promClient from 'prom-client';
import { querySudo as query } from '@lblod/mu-auth-sudo';
const jobStatusGuage = new promClient.Gauge({
  name: 'semtech_job_status_count',
  help: 'jobs per status',
  labelNames: ['status']
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

async function updateJobsPerStatusGauge() {
  const response = await query(jobStatusQuery);
  if (response.results.bindings) {
    for (const binding of response.results.bindings) {
      const status = STATUS_MAP[binding.status?.value];
      const count = parseInt(binding.jobs.value);
      jobStatusGuage.labels({status}).set(count);
    }
  }
}

export default {
  name: 'job statuses',
  cronPattern: '*/10 * * * *',
  async cronExecute() {
    const data = await updateJobsPerStatusGauge();
  },
  async metrics() {
    return await register.metrics();
  }
}
