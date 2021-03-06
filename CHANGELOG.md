# Changelog
## 0.7.1 (2022-06-28)
### :bug: Fixes
- Revert frontend bump - causes issues with previous data
## 0.7.0 (2022-06-28)
### :bug: Fixes
- Sprintf worarounds
- Graph updates
- URI updates
### :rocket: Enhancement
- Bump multiple dependencies to use latest version of mu-auth-sudo (retry mechanism on queries)
- Bump frontend
## 0.6.0 (2022-03-11)
- Added the possibility to partially update scheduled jobs
## 0.5.1 (2021-12-17)
#### :bug: Bug Fix
- CVE-2021-45046: see https://spring.io/blog/2021/12/10/log4j2-vulnerability-and-spring-boot

## 0.5.0 (2021-11-04)
### :rocket: Enhancement
- bump of various services related to deltas (fixing bugs mainly)
- Important changes related to performance
  - harvest-collector: added queue processing and use parts of comunica instead of marawa to speed up parsing.
  - harvesting-import: use parts of comunica instead of marawa to speed up parsing.

## 0.4.1 (2021-10-07)
### :rocket: Enhancement
 - Bump new version of import-sameas, which might tackle some hanging jobs if no triples were found.
## 0.4.0 (2021-09-29)
### :rocket: Enhancement
 - Scheduled jobs
 - Less strict validation for motivation
## 0.3.0 (2021-09-09)
### :bug: Fixes
 - Update producer for missing properties on besluit and artikel
### :rocket: Enhancement
 - Report on broken URl's after publishing
