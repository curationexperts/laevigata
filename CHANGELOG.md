# Changelog

## [v2.7.0](https://github.com/curationexperts/laevigata/tree/v2.7.0) (2021-02-10)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.6.1...v2.7.0)

**Security fixes:**

- Bump carrierwave from 1.3.1 to 1.3.2 [\#2081](https://github.com/curationexperts/laevigata/pull/2081) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ini from 1.3.5 to 1.3.8 [\#2074](https://github.com/curationexperts/laevigata/pull/2074) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump nokogiri from 1.10.10 to 1.11.0 [\#2073](https://github.com/curationexperts/laevigata/pull/2073) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump dot-prop from 4.2.0 to 4.2.1 [\#2072](https://github.com/curationexperts/laevigata/pull/2072) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump axios from 0.19.0 to 0.21.1 [\#2070](https://github.com/curationexperts/laevigata/pull/2070) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump http-proxy from 1.17.0 to 1.18.1 [\#2059](https://github.com/curationexperts/laevigata/pull/2059) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump node-sass from 4.12.0 to 4.14.1 [\#2058](https://github.com/curationexperts/laevigata/pull/2058) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump quill from 1.3.6 to 1.3.7 [\#2057](https://github.com/curationexperts/laevigata/pull/2057) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump elliptic from 6.4.1 to 6.5.3 [\#2041](https://github.com/curationexperts/laevigata/pull/2041) ([dependabot[bot]](https://github.com/apps/dependabot))

**Closed issues:**

- Investigate ETD Outage 10/24/2020 07:51:03 AM [\#2066](https://github.com/curationexperts/laevigata/issues/2066)
- Unable to login with TEZPROX admin account for ETDs [\#2060](https://github.com/curationexperts/laevigata/issues/2060)
- Investigate ETD Outage 2020-08-30 at 11:43am  [\#2056](https://github.com/curationexperts/laevigata/issues/2056)
- From Freshdesk: ETD Data Dump [\#2042](https://github.com/curationexperts/laevigata/issues/2042)
- Do not pin darlingtonia to master [\#2039](https://github.com/curationexperts/laevigata/issues/2039)
- Investigate ETD Outage - 07/16/2020 09:10:05 PM UTC + 8/2\(8/1?\) [\#2031](https://github.com/curationexperts/laevigata/issues/2031)

**Technical Enhancements:**

- Update supplemental file upload interface to remove Box [\#2079](https://github.com/curationexperts/laevigata/pull/2079) ([fnibbit](https://github.com/fnibbit))
- Updating ruby to the latest supported version. [\#2078](https://github.com/curationexperts/laevigata/pull/2078) ([fnibbit](https://github.com/fnibbit))
- Update config.yml for ruby 2.7.2 [\#2077](https://github.com/curationexperts/laevigata/pull/2077) ([fnibbit](https://github.com/fnibbit))
- Set up basic framework for deployment/smoke test [\#2062](https://github.com/curationexperts/laevigata/pull/2062) ([fnibbit](https://github.com/fnibbit))
- Clean spec to prevent intermittent test failures [\#2036](https://github.com/curationexperts/laevigata/pull/2036) ([bess](https://github.com/bess))
- Refactor of graduation job test [\#2035](https://github.com/curationexperts/laevigata/pull/2035) ([bess](https://github.com/bess))

## [v2.6.1](https://github.com/curationexperts/laevigata/tree/v2.6.1) (2020-07-23)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.6.0...v2.6.1)

**Security fixes:**

- Bump lodash from 4.17.13 to 4.17.19 [\#2029](https://github.com/curationexperts/laevigata/pull/2029) ([dependabot[bot]](https://github.com/apps/dependabot))

**Closed issues:**

- Rebuild ETD production server & fix any volume issues [\#2026](https://github.com/curationexperts/laevigata/issues/2026)
- Release latest laevigata [\#2008](https://github.com/curationexperts/laevigata/issues/2008)

**Technical Enhancements:**

- Prep for v1.6.1 release [\#2034](https://github.com/curationexperts/laevigata/pull/2034) ([bess](https://github.com/bess))
- Do not attempt to update the embargo if there is no embargo [\#2033](https://github.com/curationexperts/laevigata/pull/2033) ([bess](https://github.com/bess))
- Refactor test to make it more clear [\#2032](https://github.com/curationexperts/laevigata/pull/2032) ([bess](https://github.com/bess))
- handle "None" embargo length in graduation job [\#2030](https://github.com/curationexperts/laevigata/pull/2030) ([fnibbit](https://github.com/fnibbit))
- Update solr version in development and test [\#2025](https://github.com/curationexperts/laevigata/pull/2025) ([bess](https://github.com/bess))

## [v2.6.0](https://github.com/curationexperts/laevigata/tree/v2.6.0) (2020-07-07)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.5.3...v2.6.0)

**New Features:**

- Upgrade Hyrax to 2.8.0 [\#2022](https://github.com/curationexperts/laevigata/pull/2022) ([bess](https://github.com/bess))

**Fixed bugs:**

- Intermittent test failure:     Failure/Error: select '6 months', from: 'Requested Embargo Length' [\#2020](https://github.com/curationexperts/laevigata/issues/2020)
- Ensure file has time to attach before moving on [\#2021](https://github.com/curationexperts/laevigata/pull/2021) ([bess](https://github.com/bess))

**Security fixes:**

- Update Honeybadger to latest [\#2017](https://github.com/curationexperts/laevigata/pull/2017) ([bess](https://github.com/bess))
- Update yarn dependencies [\#2016](https://github.com/curationexperts/laevigata/pull/2016) ([bess](https://github.com/bess))
- Update rack to address security issue [\#2015](https://github.com/curationexperts/laevigata/pull/2015) ([bess](https://github.com/bess))
- Update capybara to address deprecation warnings [\#2013](https://github.com/curationexperts/laevigata/pull/2013) ([bess](https://github.com/bess))
- Bump sanitize from 4.6.6 to 5.2.1 [\#2007](https://github.com/curationexperts/laevigata/pull/2007) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump websocket-extensions from 0.1.3 to 0.1.4 [\#2006](https://github.com/curationexperts/laevigata/pull/2006) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump websocket-extensions from 0.1.4 to 0.1.5 [\#2005](https://github.com/curationexperts/laevigata/pull/2005) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump kaminari from 1.2.0 to 1.2.1 [\#2004](https://github.com/curationexperts/laevigata/pull/2004) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump puma from 4.3.3 to 4.3.5 [\#2003](https://github.com/curationexperts/laevigata/pull/2003) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump acorn from 5.7.3 to 5.7.4 [\#1998](https://github.com/curationexperts/laevigata/pull/1998) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump puma from 4.3.1 to 4.3.3 [\#1997](https://github.com/curationexperts/laevigata/pull/1997) ([dependabot[bot]](https://github.com/apps/dependabot))

**Closed issues:**

- Restart ETDs when we notice it's down [\#2011](https://github.com/curationexperts/laevigata/issues/2011)
- Test Box upload against Feb 2020 release of the code [\#2001](https://github.com/curationexperts/laevigata/issues/2001)
- Update Emory SSL certs [\#1999](https://github.com/curationexperts/laevigata/issues/1999)
- v2.5.3 release [\#1995](https://github.com/curationexperts/laevigata/issues/1995)
- SSL certs will expire 9 May [\#1990](https://github.com/curationexperts/laevigata/issues/1990)

**Technical Enhancements:**

- Update release process [\#2024](https://github.com/curationexperts/laevigata/pull/2024) ([bess](https://github.com/bess))
- Moves submission form links to SCO website [\#2023](https://github.com/curationexperts/laevigata/pull/2023) ([rotated8](https://github.com/rotated8))
- Upgrade bixby [\#2019](https://github.com/curationexperts/laevigata/pull/2019) ([bess](https://github.com/bess))
- Refactor to cache solr documents for better performance [\#2014](https://github.com/curationexperts/laevigata/pull/2014) ([bess](https://github.com/bess))
- Updates graduation date options, adding the next four years. [\#2009](https://github.com/curationexperts/laevigata/pull/2009) ([rotated8](https://github.com/rotated8))
- Changes the link to workshops [\#1996](https://github.com/curationexperts/laevigata/pull/1996) ([rotated8](https://github.com/rotated8))

## [v2.5.3](https://github.com/curationexperts/laevigata/tree/v2.5.3) (2020-02-14)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.5.2...v2.5.3)

**Technical Enhancements:**

- Do not request tests in languages other than english [\#1993](https://github.com/curationexperts/laevigata/pull/1993) ([bess](https://github.com/bess))
- Update README badge for circleci [\#1992](https://github.com/curationexperts/laevigata/pull/1992) ([bess](https://github.com/bess))
- Circleci fixes [\#1991](https://github.com/curationexperts/laevigata/pull/1991) ([bess](https://github.com/bess))
- Standardize capistrano deploy target names [\#1989](https://github.com/curationexperts/laevigata/pull/1989) ([maxkadel](https://github.com/maxkadel))

## [v2.5.2](https://github.com/curationexperts/laevigata/tree/v2.5.2) (2019-12-30)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.5.1...v2.5.2)

**Security fixes:**

- Bump handlebars from 4.1.2 to 4.5.3 [\#1988](https://github.com/curationexperts/laevigata/pull/1988) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump rack from 2.0.7 to 2.0.8 [\#1987](https://github.com/curationexperts/laevigata/pull/1987) ([dependabot[bot]](https://github.com/apps/dependabot))

**Closed issues:**

- Laevigata production deploy 12/17 [\#1983](https://github.com/curationexperts/laevigata/issues/1983)

## [v2.5.1](https://github.com/curationexperts/laevigata/tree/v2.5.1) (2019-12-18)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.5.0...v2.5.1)

**Closed issues:**

- Restrict access to etd-staging and -qa \(Due 12/18\) [\#1976](https://github.com/curationexperts/laevigata/issues/1976)

**Technical Enhancements:**

- Install older bundler on travis for Rails 5.1 [\#1985](https://github.com/curationexperts/laevigata/pull/1985) ([little9](https://github.com/little9))
- Access date\_modified as EST [\#1984](https://github.com/curationexperts/laevigata/pull/1984) ([little9](https://github.com/little9))

## [v2.5.0](https://github.com/curationexperts/laevigata/tree/v2.5.0) (2019-12-10)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.8...v2.5.0)

**New Features:**

- Password protect non-production instances [\#1982](https://github.com/curationexperts/laevigata/pull/1982) ([bess](https://github.com/bess))

**Fixed bugs:**

- Display date\_uploaded as EST [\#1981](https://github.com/curationexperts/laevigata/pull/1981) ([little9](https://github.com/little9))

**Security fixes:**

- Bump puma from 3.12.0 to 3.12.2 [\#1979](https://github.com/curationexperts/laevigata/pull/1979) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump rubyzip from 1.2.2 to 1.3.0 [\#1972](https://github.com/curationexperts/laevigata/pull/1972) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump loofah from 2.2.3 to 2.3.1 [\#1971](https://github.com/curationexperts/laevigata/pull/1971) ([dependabot[bot]](https://github.com/apps/dependabot))

**Closed issues:**

- Freshdesk: Emory November Registrar Data [\#1978](https://github.com/curationexperts/laevigata/issues/1978)
- Force publish and add Legacy graduation dates to these SCO Created Legacy ETDs that were marked Inactive and did not migrate in 2018 [\#1977](https://github.com/curationexperts/laevigata/issues/1977)
- Give Max access to Freshdesk [\#1975](https://github.com/curationexperts/laevigata/issues/1975)
- Add Max to DCE hosting AWS [\#1974](https://github.com/curationexperts/laevigata/issues/1974)
- Release v2.4.8 to production  [\#1970](https://github.com/curationexperts/laevigata/issues/1970)
- Timestamp off on Review Submissions Page \(Due 11/21\) [\#1964](https://github.com/curationexperts/laevigata/issues/1964)

## [v2.4.8](https://github.com/curationexperts/laevigata/tree/v2.4.8) (2019-11-04)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.7...v2.4.8)

**Fixed bugs:**

- Missing block on on Submission Review page [\#1963](https://github.com/curationexperts/laevigata/issues/1963)

**Closed issues:**

- Fix typo in admin uid [\#1968](https://github.com/curationexperts/laevigata/issues/1968)
- Fix Emory production nightly backups [\#1966](https://github.com/curationexperts/laevigata/issues/1966)
- Reviewer, Admin Changes [\#1965](https://github.com/curationexperts/laevigata/issues/1965)

**Technical Enhancements:**

- Changes the instructions button on the homepage. [\#1969](https://github.com/curationexperts/laevigata/pull/1969) ([rotated8](https://github.com/rotated8))

## [v2.4.7](https://github.com/curationexperts/laevigata/tree/v2.4.7) (2019-10-24)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.6...v2.4.7)

**Closed issues:**

- Release v2.4.6 to production [\#1960](https://github.com/curationexperts/laevigata/issues/1960)
- Run September registrar data [\#1959](https://github.com/curationexperts/laevigata/issues/1959)
- ETD Data Dump [\#1957](https://github.com/curationexperts/laevigata/issues/1957)
- CC Fran for emails [\#1956](https://github.com/curationexperts/laevigata/issues/1956)

**Technical Enhancements:**

- Fix for Rollins submission [\#1967](https://github.com/curationexperts/laevigata/pull/1967) ([little9](https://github.com/little9))
- Updates homepage. [\#1961](https://github.com/curationexperts/laevigata/pull/1961) ([rotated8](https://github.com/rotated8))

## [v2.4.6](https://github.com/curationexperts/laevigata/tree/v2.4.6) (2019-09-19)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.5...v2.4.6)

**Security fixes:**

- Bump devise from 4.6.1 to 4.7.1 [\#1955](https://github.com/curationexperts/laevigata/pull/1955) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump mixin-deep from 1.3.1 to 1.3.2 [\#1953](https://github.com/curationexperts/laevigata/pull/1953) ([dependabot[bot]](https://github.com/apps/dependabot))

**Closed issues:**

- Deploy v2.4.5 [\#1954](https://github.com/curationexperts/laevigata/issues/1954)

**Technical Enhancements:**

- Hard code fpici as an email cc default [\#1958](https://github.com/curationexperts/laevigata/pull/1958) ([bess](https://github.com/bess))

## [v2.4.5](https://github.com/curationexperts/laevigata/tree/v2.4.5) (2019-08-23)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.4...v2.4.5)

**Technical Enhancements:**

- Upgrade nokogiri again for security fix [\#1952](https://github.com/curationexperts/laevigata/pull/1952) ([bess](https://github.com/bess))
- Upgrade nokogiri and pg [\#1951](https://github.com/curationexperts/laevigata/pull/1951) ([bess](https://github.com/bess))

## [v2.4.4](https://github.com/curationexperts/laevigata/tree/v2.4.4) (2019-07-25)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.3...v2.4.4)

## [v2.4.3](https://github.com/curationexperts/laevigata/tree/v2.4.3) (2019-07-25)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.2...v2.4.3)

## [v2.4.2](https://github.com/curationexperts/laevigata/tree/v2.4.2) (2019-07-18)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.1...v2.4.2)

## [v2.4.1](https://github.com/curationexperts/laevigata/tree/v2.4.1) (2019-07-11)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.0...v2.4.1)

## [v2.4.0](https://github.com/curationexperts/laevigata/tree/v2.4.0) (2019-07-08)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.3.5...v2.4.0)

## [v2.3.5](https://github.com/curationexperts/laevigata/tree/v2.3.5) (2019-06-04)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.3.4...v2.3.5)

## [v2.3.4](https://github.com/curationexperts/laevigata/tree/v2.3.4) (2019-03-20)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.3.3...v2.3.4)

## [v2.3.3](https://github.com/curationexperts/laevigata/tree/v2.3.3) (2019-02-27)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.3.2...v2.3.3)

## [v2.3.2](https://github.com/curationexperts/laevigata/tree/v2.3.2) (2019-02-27)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.3.1...v2.3.2)

## [v2.3.1](https://github.com/curationexperts/laevigata/tree/v2.3.1) (2019-02-14)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.3.0...v2.3.1)

## [v2.3.0](https://github.com/curationexperts/laevigata/tree/v2.3.0) (2019-01-21)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.2.1...v2.3.0)

## [v2.2.1](https://github.com/curationexperts/laevigata/tree/v2.2.1) (2019-01-10)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.1.3...v2.2.1)

## [v2.1.3](https://github.com/curationexperts/laevigata/tree/v2.1.3) (2018-11-20)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.2.0...v2.1.3)

## [v2.2.0](https://github.com/curationexperts/laevigata/tree/v2.2.0) (2018-11-15)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.1.2...v2.2.0)

## [v2.1.2](https://github.com/curationexperts/laevigata/tree/v2.1.2) (2018-10-30)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.1.1...v2.1.2)

## [v2.1.1](https://github.com/curationexperts/laevigata/tree/v2.1.1) (2018-10-29)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.1.0...v2.1.1)

## [v2.1.0](https://github.com/curationexperts/laevigata/tree/v2.1.0) (2018-10-26)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.6...v2.1.0)

## [v2.0.6](https://github.com/curationexperts/laevigata/tree/v2.0.6) (2018-09-18)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.5...v2.0.6)

## [v2.0.5](https://github.com/curationexperts/laevigata/tree/v2.0.5) (2018-09-04)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.4...v2.0.5)

## [v2.0.4](https://github.com/curationexperts/laevigata/tree/v2.0.4) (2018-08-30)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.3...v2.0.4)

## [v2.0.3](https://github.com/curationexperts/laevigata/tree/v2.0.3) (2018-08-30)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.2...v2.0.3)

## [v2.0.2](https://github.com/curationexperts/laevigata/tree/v2.0.2) (2018-08-29)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.1...v2.0.2)

## [v2.0.1](https://github.com/curationexperts/laevigata/tree/v2.0.1) (2018-08-29)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.1-beta1...v2.0.1)

## [v2.0.1-beta1](https://github.com/curationexperts/laevigata/tree/v2.0.1-beta1) (2018-08-28)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0...v2.0.1-beta1)

## [v2.0.0](https://github.com/curationexperts/laevigata/tree/v2.0.0) (2018-08-27)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-beta10...v2.0.0)

## [v2.0.0-beta10](https://github.com/curationexperts/laevigata/tree/v2.0.0-beta10) (2018-08-27)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-beta9...v2.0.0-beta10)

## [v2.0.0-beta9](https://github.com/curationexperts/laevigata/tree/v2.0.0-beta9) (2018-08-23)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-beta8...v2.0.0-beta9)

## [v2.0.0-beta8](https://github.com/curationexperts/laevigata/tree/v2.0.0-beta8) (2018-08-22)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-beta7...v2.0.0-beta8)

## [v2.0.0-beta7](https://github.com/curationexperts/laevigata/tree/v2.0.0-beta7) (2018-08-21)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-beta6...v2.0.0-beta7)

## [v2.0.0-beta6](https://github.com/curationexperts/laevigata/tree/v2.0.0-beta6) (2018-08-21)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-beta5...v2.0.0-beta6)

## [v2.0.0-beta5](https://github.com/curationexperts/laevigata/tree/v2.0.0-beta5) (2018-08-20)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-beta4...v2.0.0-beta5)

## [v2.0.0-beta4](https://github.com/curationexperts/laevigata/tree/v2.0.0-beta4) (2018-08-20)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-beta3...v2.0.0-beta4)

## [v2.0.0-beta3](https://github.com/curationexperts/laevigata/tree/v2.0.0-beta3) (2018-08-19)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-beta2...v2.0.0-beta3)

## [v2.0.0-beta2](https://github.com/curationexperts/laevigata/tree/v2.0.0-beta2) (2018-08-17)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-beta1...v2.0.0-beta2)

## [v2.0.0-beta1](https://github.com/curationexperts/laevigata/tree/v2.0.0-beta1) (2018-08-09)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.6.9...v2.0.0-beta1)

## [v1.6.9](https://github.com/curationexperts/laevigata/tree/v1.6.9) (2018-07-27)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.6.7...v1.6.9)

## [v1.6.7](https://github.com/curationexperts/laevigata/tree/v1.6.7) (2018-07-18)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.6.8...v1.6.7)

## [v1.6.8](https://github.com/curationexperts/laevigata/tree/v1.6.8) (2018-07-18)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.6.6...v1.6.8)

## [v1.6.6](https://github.com/curationexperts/laevigata/tree/v1.6.6) (2018-06-25)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.6.5...v1.6.6)

## [v1.6.5](https://github.com/curationexperts/laevigata/tree/v1.6.5) (2018-06-22)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-alpha+sha.b05aa3a...v1.6.5)

## [v2.0.0-alpha+sha.b05aa3a](https://github.com/curationexperts/laevigata/tree/v2.0.0-alpha+sha.b05aa3a) (2018-06-14)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-alpha+sha.3bcf008...v2.0.0-alpha+sha.b05aa3a)

## [v2.0.0-alpha+sha.3bcf008](https://github.com/curationexperts/laevigata/tree/v2.0.0-alpha+sha.3bcf008) (2018-06-12)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.0.0-alpha+sha.8e864f6...v2.0.0-alpha+sha.3bcf008)

## [v2.0.0-alpha+sha.8e864f6](https://github.com/curationexperts/laevigata/tree/v2.0.0-alpha+sha.8e864f6) (2018-05-31)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.6.4...v2.0.0-alpha+sha.8e864f6)

## [v1.6.4](https://github.com/curationexperts/laevigata/tree/v1.6.4) (2018-05-23)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.6.3...v1.6.4)

## [v1.6.3](https://github.com/curationexperts/laevigata/tree/v1.6.3) (2018-05-18)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.6.2...v1.6.3)

## [v1.6.2](https://github.com/curationexperts/laevigata/tree/v1.6.2) (2018-05-02)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.6.1...v1.6.2)

## [v1.6.1](https://github.com/curationexperts/laevigata/tree/v1.6.1) (2018-04-26)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.6.0...v1.6.1)

## [v1.6.0](https://github.com/curationexperts/laevigata/tree/v1.6.0) (2018-04-25)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.6...v1.6.0)

## [v1.6](https://github.com/curationexperts/laevigata/tree/v1.6) (2018-04-25)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.5.3...v1.6)

## [v1.5.3](https://github.com/curationexperts/laevigata/tree/v1.5.3) (2018-04-24)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.5.2...v1.5.3)

## [v1.5.2](https://github.com/curationexperts/laevigata/tree/v1.5.2) (2018-04-18)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.5.1...v1.5.2)

## [v1.5.1](https://github.com/curationexperts/laevigata/tree/v1.5.1) (2018-04-10)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.5...v1.5.1)

## [v1.5](https://github.com/curationexperts/laevigata/tree/v1.5) (2018-04-07)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.4...v1.5)

## [v1.4](https://github.com/curationexperts/laevigata/tree/v1.4) (2018-03-21)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.3.5...v1.4)

## [v1.3.5](https://github.com/curationexperts/laevigata/tree/v1.3.5) (2018-03-14)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.3.4...v1.3.5)

## [v1.3.4](https://github.com/curationexperts/laevigata/tree/v1.3.4) (2018-03-13)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.3.3...v1.3.4)

## [v1.3.3](https://github.com/curationexperts/laevigata/tree/v1.3.3) (2018-03-06)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.3.2...v1.3.3)

## [v1.3.2](https://github.com/curationexperts/laevigata/tree/v1.3.2) (2018-03-05)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.3.1...v1.3.2)

## [v1.3.1](https://github.com/curationexperts/laevigata/tree/v1.3.1) (2018-02-26)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.3...v1.3.1)

## [v1.3](https://github.com/curationexperts/laevigata/tree/v1.3) (2018-02-26)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.2.1...v1.3)

## [v1.2.1](https://github.com/curationexperts/laevigata/tree/v1.2.1) (2018-01-22)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.2.0...v1.2.1)

## [v1.2.0](https://github.com/curationexperts/laevigata/tree/v1.2.0) (2017-12-01)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.1.1...v1.2.0)

## [v1.1.1](https://github.com/curationexperts/laevigata/tree/v1.1.1) (2017-11-30)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.1.0...v1.1.1)

## [v1.1.0](https://github.com/curationexperts/laevigata/tree/v1.1.0) (2017-11-30)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.0.3...v1.1.0)

## [v1.0.3](https://github.com/curationexperts/laevigata/tree/v1.0.3) (2017-11-03)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.0.2...v1.0.3)

## [v1.0.2](https://github.com/curationexperts/laevigata/tree/v1.0.2) (2017-09-13)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.0.1...v1.0.2)

## [v1.0.1](https://github.com/curationexperts/laevigata/tree/v1.0.1) (2017-09-12)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.0.0...v1.0.1)

## [v1.0.0](https://github.com/curationexperts/laevigata/tree/v1.0.0) (2017-08-23)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.0.rc3...v1.0.0)

## [v1.0.rc3](https://github.com/curationexperts/laevigata/tree/v1.0.rc3) (2017-08-22)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.0.rc2...v1.0.rc3)

## [v1.0.rc2](https://github.com/curationexperts/laevigata/tree/v1.0.rc2) (2017-08-21)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v1.0.rc1...v1.0.rc2)

## [v1.0.rc1](https://github.com/curationexperts/laevigata/tree/v1.0.rc1) (2017-08-17)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/ebe8db0ab0daffa19e3080def98e42ac55825bc2...v1.0.rc1)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
