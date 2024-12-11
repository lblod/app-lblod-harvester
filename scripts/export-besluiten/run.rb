#!/usr/bin/env ruby

require 'bundler/inline'
require 'yaml'
require 'securerandom'
require 'date'
require 'rdf/vocab'
require 'tty-prompt'
require 'rdf/turtle'
require 'rdf/reasoner'

$stdout.sync = true
ENV['LOG_SPARQL_ALL']='false'
ENV['MU_SPARQL_ENDPOINT']='http://virtuoso:8890/sparql'
ENV['MU_SPARQL_TIMEOUT']='180'
require 'mu/auth-sudo'



def sparql_escape_uri(value)
  '<' + value.to_s.gsub(/[\\"<>]/) { |s| '\\' + s } + '>'
end

def sparql_escape_string(str)
  '"""' + str.gsub(/[\\"]/) { |s| '\\' + s } + '"""'
end

def export_besluiten_links()
  repository = RDF::Repository.new
  # bekrachtigen gemeenteraad
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit ext:title ?title.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000011>.
}
WHERE {
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000005>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "eedaflegging"))
 FILTER(CONTAINS(LCASE(?title), "gemeenteraad"))
}
EOF
  repository << Mu::AuthSudo.query(query)
  # bekrachtigen aangewezen burgemeester
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:title ?title.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/7b038cc40bba10bec833ecfe6f15bc7a>.
}
WHERE {
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000005>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "eedaflegging") || CONTAINS(LCASE(?title), "aanduid"))
 FILTER(CONTAINS(LCASE(?title), "burgemeester"))
}
EOF
  repository << Mu::AuthSudo.query(query)
  # bekrachtigen voorzitter gemeenteraad
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit ext:title ?title.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000012>.
}
WHERE {
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000005>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "voorzitter van de gemeenteraad"))
}
EOF
  repository << Mu::AuthSudo.query(query)
  # bekrachtigen schepenen
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit ext:title ?title.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000014>, <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/59a90e03-4f22-4bb9-8c91-132618db4b38> .
}
WHERE {
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000005>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "de schepenen"))
 FILTER(CONTAINS(LCASE(?title), "verkie"))
}
EOF
  repository << Mu::AuthSudo.query(query)
  # bekrachtigen leden bcsd
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit ext:title ?title.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e000019>.
}
WHERE {
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000007>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "leden"))
}
EOF
  repository << Mu::AuthSudo.query(query)
  # bekrachtigen voorzitter bcsd
  query = <<~EOF
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX org: <http://www.w3.org/ns/org#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
CONSTRUCT {
  ?besluit ext:origin ?origin.
  ?besluit ext:bekrachtigtMandatarissenVoor ?orgaanInTijd.
  ?besluit ext:title ?title.
  ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
  ?besluit ext:forRole <http://data.vlaanderen.be/id/concept/BestuursfunctieCode/5ab0e9b8a3b2ca7c5e00001a>.
}
WHERE {
 ?zitting a besluit:Zitting.
 ?zitting <http://www.w3.org/ns/prov#wasDerivedFrom> ?origin.
 ?zitting  <http://data.europa.eu/eli/ontology#passedBy> | besluit:isGehoudenDoor ?orgaanInTijd.
 ?orgaanInTijd mandaat:isTijdspecialisatieVan ?org.
 ?org besluit:classificatie <http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/5ab0e9b8a3b2ca7c5e000007>.
 ?zitting prov:startedAtTime ?date.
 FILTER(?date > "2024-12-01T18:30:27.495Z"^^xsd:dateTime)
 ?zitting besluit:behandelt / ^dct:subject / prov:generated ?besluit.
 ?besluit <http://data.europa.eu/eli/ontology#title> ?title.
 ?besluit <http://www.w3.org/ns/prov#wasDerivedFrom> ?besluitOrigin.
 FILTER(CONTAINS(LCASE(?title), "voorzitter"))
}
EOF
  repository << Mu::AuthSudo.query(query)
  repository
end

def ensure_dir(path)
 unless Dir.exist?(path)
   Dir.mkdir(path)
 end
end

output_dir = "/app/exports/"
ensure_dir(output_dir)
repo=export_besluiten_links()
timestamp=`date +%Y%0m%0d%0H%0M%0S`.strip.to_i

path = File.join(output_dir, "export-bekrachtigingen.ttl")
File.open(path, 'w') do |file|
  file.write repo.dump(:ntriples)
end
puts("Exported #{repo.size} statements to #{path}")
