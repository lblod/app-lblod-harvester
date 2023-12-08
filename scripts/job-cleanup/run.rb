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
end
require 'mu/auth-sudo'
ENV['MU_SPARQL_ENDPOINT']='http://database:8890/sparql'
COGS = RDF::Vocabulary.new("http://vocab.deri.ie/cogs#")
SECONDS_IN_DAY=86400

def get_output_files_for(job)
  result = Mu::AuthSudo.query(
    <<~EOF
SELECT (COUNT(?file) as ?files)
WHERE {
  ?task <http://purl.org/dc/terms/isPartOf> <#{job.to_s}>.
  ?task <http://redpencil.data.gift/vocabularies/tasks/resultsContainer> ?container.
  ?container <http://redpencil.data.gift/vocabularies/tasks/hasFile> ?file.
}
EOF
  )
  nb_files = result[0][:files].to_i
  offset = 0
  files = []
  while offset < nb_files do
    result = Mu::AuthSudo.query(
      <<~EOF
SELECT ?file ?fileOnDisk
WHERE {
{ SELECT distinct ?file ?fileOnDisk WHERE {
  ?task <http://purl.org/dc/terms/isPartOf> <#{job.to_s}>.
  ?task <http://redpencil.data.gift/vocabularies/tasks/resultsContainer> ?container.
  ?container <http://redpencil.data.gift/vocabularies/tasks/hasFile> ?file.
  ?fileOnDisk <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#dataSource> ?file.
} ORDER BY ?file ?source }
} LIMIT 5000 OFFSET #{offset}
EOF
    )
    files = files.concat(result)
    offset = offset + 5000
  end
  files
end

def remove_file_from_disk(file)
  path_on_disk = file[:fileOnDisk].to_s.gsub('share://','/project/data/files/')
  File.delete(path_on_disk)
end

prompt = TTY::Prompt.new
prompt.say("\n\n")
prompt.say("welcome to the interactive cleaning tool, please answer some questions before we can proceed")
begin
  has_jobs = Mu::AuthSudo.query("ASK { ?job a <#{COGS.Job.to_s}> }")
rescue Exception => e
  prompt.error(e)
  has_jobs = false
end
unless has_jobs
  prompt.error("no jobs found or database unreachable, exiting")
  exit(1)
end

how_old = prompt.select("How old must job be before it can be deleted") do |menu|
  menu.choice value: :hour, name: "an hour"
  menu.choice value: :day, name: "24 hours"
  menu.choice value: :week, name: "7 days"
  menu.choice value: :month, name: "30 days"
end

days = case how_old
       when :hour
         3600
       when :day
         SECONDS_IN_DAY
       when :week
         SECONDS_IN_DAY * 7
       when :month
         SECONDS_IN_DAY * 30
       end

jobs = Mu::AuthSudo.query(
<<~EOF
SELECT ?status (COUNT(?job) as ?count)
WHERE {
?job a <#{COGS.Job.to_s}>;
   <http://www.w3.org/ns/adms#status> ?status;
   <http://purl.org/dc/terms/modified> ?modified.
   FILTER(?modified < NOW()- #{days})
}
GROUP BY ?status
EOF
)
which_status = prompt.select("What status should the job have?") do |menu|
  jobs.each do |job|
    menu.choice name: "#{job[:status].to_s[48..-1]} (#{job[:count]} jobs)" , value: job[:status]
  end
end

prompt.say("preparing to delete all jobs older than #{days/SECONDS_IN_DAY} day(s) with status #{which_status.to_s}")
nb_files = Mu::AuthSudo.query(
  <<~EOF
SELECT (COUNT(?file) as ?files)
WHERE {
?job a <#{COGS.Job.to_s}>;
   <http://www.w3.org/ns/adms#status> <#{which_status.to_s}>;
   <http://purl.org/dc/terms/modified> ?modified.
   FILTER(?modified < NOW()- #{days})
  ?task <http://purl.org/dc/terms/isPartOf> ?job.
  ?task <http://redpencil.data.gift/vocabularies/tasks/resultsContainer> ?container.
  ?container <http://redpencil.data.gift/vocabularies/tasks/hasFile> ?file.
}
EOF
)
nb_graphs = Mu::AuthSudo.query(
  <<~EOF
SELECT (COUNT(?graph) as ?graphs)
WHERE {
?job a <#{COGS.Job.to_s}>;
   <http://www.w3.org/ns/adms#status> <#{which_status.to_s}>;
   <http://purl.org/dc/terms/modified> ?modified.
   FILTER(?modified < NOW()- #{days})
  ?task <http://purl.org/dc/terms/isPartOf> ?job.
  ?task <http://redpencil.data.gift/vocabularies/tasks/resultsContainer> ?container.
  ?container  <http://redpencil.data.gift/vocabularies/tasks/hasGraph> ?graph.
}
EOF
)

delete_related_outputs = false
if nb_files[0][:files] > 0 or nb_graphs[0][:graphs] > 0
  delete_related_outputs = prompt.yes?("#{nb_files[0][:files]} files and #{nb_graphs[0][:graphs]} graphs were created in these jobs, delete these as well?")
end

jobs = Mu::AuthSudo.query(
  <<~EOF
SELECT DISTINCT ?job
WHERE {
?job a <#{COGS.Job.to_s}>;
   <http://www.w3.org/ns/adms#status> <#{which_status.to_s}>;
   <http://purl.org/dc/terms/modified> ?modified.
   FILTER(?modified < NOW()- #{days})
}
EOF
)
jobs.each do |job|
  begin
    job_uri = job[:job]
    files = get_output_files_for(job_uri)
    prompt.say("removing #{files.length} files linked to #{job_uri} (from disk and db)")
    files.each do |file|
      begin
        remove_file_from_disk(file)
      rescue
        prompt.warn("failed to remove #{file[:fileOnDisk]} from disk")
      end
      jobs = Mu::AuthSudo.query(
        <<~EOF
DELETE
{
   ?s ?p <#{file[:file]}>.
   <#{file[:file]}> ?fileP ?fileO.
   <#{file[:fileOnDisk]}> ?diskP ?diskO.
} WHERE {
  { ?s ?p <#{file[:file]}> }
  UNION {
  <#{file[:file]}> ?fileP ?fileO.
  }
UNION {
  <#{file[:fileOnDisk]}> ?diskP ?diskO.
}
}
EOF
      )
    end
    prompt.say("removing file metadata")
  rescue Exception => e
    prompt.error("Error while removing #{job[:job]}: #{e}")
    exit(1)
  end
end

