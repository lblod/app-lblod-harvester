
;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)

(setf *delta-handlers* nil)
;; (add-delta-logger)
(add-delta-messenger "http://deltanotifier/")

;;;;;;;;;;;;;;;;;
;;; configuration
(in-package :client)
(setf *log-sparql-query-roundtrip* t)
(setf *backend* "http://virtuoso:8890/sparql")

(in-package :server)
(setf *log-incoming-requests-p* t)


;;;;;;;;;;;;;;;;;
;;; access rights

(in-package :acl)

(defparameter *access-specifications* nil
  "All known ACCESS specifications.")

(defparameter *graphs* nil
  "All known GRAPH-SPECIFICATION instances.")

(defparameter *rights* nil
  "All known GRANT instances connecting ACCESS-SPECIFICATION to GRAPH.")

(define-prefixes
  :besluit "http://data.vlaanderen.be/ns/besluit#"
  :cogs "http://vocab.deri.ie/cogs#"
  :core "http://open-services.net/ns/core#"
  :skos "http://www.w3.org/2004/02/skos/core#"
  :dcat "http://www.w3.org/ns/dcat#"
  :dct "http://purl.org/dc/terms/"
  :eli "http://data.europa.eu/eli/ontology#"
  :foaf "http://xmlns.com/foaf/0.1/"
  :generiek "https://data.vlaanderen.be/ns/generiek#"
  :harvesting "http://lblod.data.gift/vocabularies/harvesting/"
  :mandaat "http://data.vlaanderen.be/ns/mandaat#"
  :ndo "http://oscaf.sourceforge.net/ndo.html#"
  :nfo "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#"
  :person "http://www.w3.org/ns/person#"
  :schema "http://schema.org/"
  :security "http://lblod.data.gift/vocabularies/security/"
  :tasks "http://redpencil.data.gift/vocabularies/tasks/"
  :wot "https://www.w3.org/2019/wot/security#")

(define-graph harvesting ("http://mu.semte.ch/graphs/harvesting")
  ("tasks:Task" -> _ )
  ("cogs:Job" -> _ )
  ("cogs:ScheduledJob" -> _ )
  ("tasks:ScheduledTask" -> _ )
  ("tasks:CronSchedule" -> _ )
  ("schema:repeatFrequency" -> _ )
  ("core:Error" -> _ )
  ("harvesting:HarvestingCollection" -> _ )
  ("nfo:RemoteDataObject" -> _ )
  ("nfo:FileDataObject" -> _ )
  ("nfo:DataContainer" -> _ )
  ("ndo:DownloadEvent" -> _ )
  ("dcat:Dataset" -> _ )
  ("dcat:Distribution" -> _ )
  ("dcat:Catalog" -> _ )
  ("security:AuthenticationConfiguration" -> _ )
  ("security:Credentials" -> _ )
  ("security:BasicAuthenticationCredentials" -> _ )
  ("security:OAuth2Credentials" -> _ )
  ("wot:SecurityScheme" -> _ )
  ("wot:BasicSecurityScheme" -> _ )
  ("wot:OAuth2SecurityScheme" -> _ ))

(define-graph harvesting-public ("http://mu.semte.ch/graphs/harvesting")
  ("nfo:RemoteDataObject" -> _)
  ("nfo:FileDataObject" -> _))

(define-graph public ("http://mu.semte.ch/graphs/public")
  ("besluit:Besluit" -> _)
  ("besluit:Zitting" -> _)
  ("besluit:Bestuursorgaan" -> _)
  ("foaf:Document" -> _)
  ("besluit:Agendapunt" -> _)
  ("skos:Concept" -> _)
  ("dct:Agent" -> _)
  ("besluit:Artikel" -> _)
  ("besluit:BehandelingVanAgendapunt" -> _)
  ("besluit:Bestuurseenheid" -> _)
  ("generiek:DocumentOnderdeel" -> _)
  ("eli:LegalExpression" -> _)
  ("mandaat:Mandataris" -> _)
  ("eli:LegalResource" -> _)
  ("eli:LegalResourceSubdivision" -> _)
  ("besluit:Stemming" -> _)
  ("besluit:Vergaderactiviteit" -> _)
  ("mandaat:Mandaat" -> _)
  ("person:Person" -> _))

(supply-allowed-group "public")

(grant (read)
       :to public
       :for "public")

(grant (read)
       :to harvesting-public
       :for "public")

(supply-allowed-group "logged-in"
  :query "PREFIX session: <http://mu.semte.ch/vocabularies/session/>
      SELECT DISTINCT ?account WHERE {
      <SESSION_ID> session:account ?account.
      }")

(grant (read write)
       :to harvesting
       :for "logged-in")
