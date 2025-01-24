#!/usr/bin/env ruby

require 'bundler/inline'
require 'yaml'
require 'securerandom'
require 'date'
require 'csv'

$stdout.sync = true
print "installing dependencies..."
gemfile do
  source 'https://rubygems.org'
  gem 'mu-auth-sudo'
  gem 'rdf-vocab', '~> 3.3'
  gem 'tty-prompt'
  gem 'terminal-table'
  gem 'ruby-progressbar'
end
ENV['LOG_SPARQL_ALL']='false'
ENV['MU_SPARQL_ENDPOINT']='http://database:8890/sparql'
require 'mu/auth-sudo'

def get_scheduled_jobs
  result = Mu::AuthSudo.query(
    <<~EOF
PREFIX cogs: <http://vocab.deri.ie/cogs#>
SELECT distinct ?job ?title ?interval
WHERE {
  ?job a cogs:ScheduledJob;
<http://redpencil.data.gift/vocabularies/tasks/schedule>/<http://schema.org/repeatFrequency> ?interval;
   <http://purl.org/dc/terms/title> ?title.
} ORDER BY ?title
EOF
  )
  result
end

def get_avg_length_for_job(scheduled_job)
  result = Mu::AuthSudo.query(
    <<~EOF
PREFIX dct:  <http://purl.org/dc/terms/>
PREFIX adms: <http://www.w3.org/ns/adms#>
SELECT ?job ?time
WHERE {
  ?job dct:creator <#{scheduled_job}>;
       adms:status <http://redpencil.data.gift/id/concept/JobStatus/success>;
       dct:modified ?modified;
       dct:created ?created.
       BIND(?modified - ?created AS ?time)
}
EOF
  )
  if result.size > 0
    result.map{ |x| x["time"].value.to_i / 60 }.reduce{ |x,y| x+y } / result.size
  end
end
prompt = TTY::Prompt.new
prompt.say("\n\n")
scheduled_jobs = get_scheduled_jobs
prompt.say("job optimizer found #{scheduled_jobs.size} scheduled jobs to optimize.\ncalculating avg length of succesfull runs...")
scheduled_jobs.each do |job|
  time = get_avg_length_for_job(job["job"])
  unless time
    time = prompt.ask("no time found for job with title #{job["title"]}, how much time should we reserve") do |q|
      q.required true
      q.convert :int
      q.default 15
    end
  end
  job[:time_in_minutes] = time
end

hour_period_min = 6
hour_period_max = 23
# how many minutes can a job run out (expressed in percentage of job time)
percentage_buffer=0.05

buffer_time = scheduled_jobs.map{ |row| row[:time_in_minutes].to_i * percentage_buffer}.sum.ceil

hour=hour_period_min
minute = 0
day_of_interval = 1
scheduled_jobs.each do |job|
  if minute >= 60
    hour = hour + (minute/60).floor
    minute = minute % 60
  end
  if hour > hour_period_max
    day_of_interval = day_of_interval + 1
    hour = hour_period_min
    minute = 0
  end
  job[:minute] = minute
  job[:hour] = hour
  job[:day] =  day_of_interval
  buffer_time = (job[:time_in_minutes].to_i * percentage_buffer).round
  minute = minute + job[:time_in_minutes].to_i + buffer_time
end
days_required = day_of_interval
prompt.say "this will require #{days_required} days to schedule all jobs"
table = Terminal::Table.new(headings: ["title", "old interval", "new interval"]) do |t|
  scheduled_jobs.each { |row| t << [ row[:title], row[:interval],"#{row[:minute]} #{row[:hour]} #{row[:day]}/#{days_required} * *" ]}
end

prompt.say(table)
apply_schedule=prompt.yes?("apply the above schedule?")
if apply_schedule
  progressbar = ProgressBar.create(total: scheduled_jobs.size, starting_at: 0)
  scheduled_jobs.each do |job|
    Mu::AuthSudo.update(
    <<~EOF
PREFIX cogs: <http://vocab.deri.ie/cogs#>
DELETE { GRAPH ?g { ?schedule <http://schema.org/repeatFrequency> ?old_schedule}}
INSERT { GRAPH ?g { ?schedule <http://schema.org/repeatFrequency> "#{job[:minute]} #{job[:hour]} #{job[:day]}/#{days_required} * *" }}
WHERE {
  GRAPH ?g {
    <#{job[:job]}> a cogs:ScheduledJob;
    <http://redpencil.data.gift/vocabularies/tasks/schedule> ?schedule.
?schedule <http://schema.org/repeatFrequency> ?old_schedule.
  }
}
EOF
    )
    progressbar.increment
  end
end
prompt.ok("all done")
