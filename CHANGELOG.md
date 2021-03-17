# Changelog

## [v2.7.1](https://github.com/curationexperts/laevigata/tree/v2.7.1) (2021-03-17)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.7.0...v2.7.1)

**Fixed bugs:**

- Embargo visibility is not set correctly on newly created and submitted ETDs [\#2065](https://github.com/curationexperts/laevigata/issues/2065)

**Closed issues:**

- Review and merge PR for removing migration code [\#2131](https://github.com/curationexperts/laevigata/issues/2131)
- Handle URI.escape/URI.unescape warnings [\#2108](https://github.com/curationexperts/laevigata/issues/2108)
- Configure test coverage reporting [\#2107](https://github.com/curationexperts/laevigata/issues/2107)
- Vue UI Test Suite [\#2102](https://github.com/curationexperts/laevigata/issues/2102)
- Rename master branch --\> main [\#2091](https://github.com/curationexperts/laevigata/issues/2091)
- Review and update README [\#2084](https://github.com/curationexperts/laevigata/issues/2084)
- Document procedure for manually submitting and attaching large files [\#2080](https://github.com/curationexperts/laevigata/issues/2080)
- Reserve Instance for Prod [\#2075](https://github.com/curationexperts/laevigata/issues/2075)
- Address outstanding dependency updates \(Dependabot\) [\#2071](https://github.com/curationexperts/laevigata/issues/2071)
- Update ETD Supplemental File upload option [\#2069](https://github.com/curationexperts/laevigata/issues/2069)
- Update Ruby Version [\#2064](https://github.com/curationexperts/laevigata/issues/2064)
- SPIKE: What are our options for attaching large files [\#2054](https://github.com/curationexperts/laevigata/issues/2054)
- Spike: How viable does Vue appear to be as a framework?  [\#2053](https://github.com/curationexperts/laevigata/issues/2053)
- Create a checklist of tasks that need to happen for the real cutover [\#2050](https://github.com/curationexperts/laevigata/issues/2050)
- Cut and deploy our last \(hopefully?\) Ubuntu 16.04 release of Laevigata [\#2046](https://github.com/curationexperts/laevigata/issues/2046)
- Remove legacy migration code to speed up CI [\#2040](https://github.com/curationexperts/laevigata/issues/2040)
- Remove automated runs of the graduation job [\#2038](https://github.com/curationexperts/laevigata/issues/2038)

**Technical Enhancements:**

- Update hydra head [\#2132](https://github.com/curationexperts/laevigata/pull/2132) ([fnibbit](https://github.com/fnibbit))
- Refactor workflow setup to improve performance [\#2130](https://github.com/curationexperts/laevigata/pull/2130) ([mark-dce](https://github.com/mark-dce))
- Refactor the GraduationService for improved performance [\#2121](https://github.com/curationexperts/laevigata/pull/2121) ([mark-dce](https://github.com/mark-dce))
- Remove obsolete diagnostic code for partials [\#2118](https://github.com/curationexperts/laevigata/pull/2118) ([mark-dce](https://github.com/mark-dce))
- Only run expensive setup where needed in Proquest spec [\#2117](https://github.com/curationexperts/laevigata/pull/2117) ([mark-dce](https://github.com/mark-dce))
- Handle additional GraduationHelper edge cases [\#2115](https://github.com/curationexperts/laevigata/pull/2115) ([mark-dce](https://github.com/mark-dce))
- Clear date input field in embargo edit spec [\#2113](https://github.com/curationexperts/laevigata/pull/2113) ([fnibbit](https://github.com/fnibbit))
- Upgrade jest to address downstream dependency vulnerability [\#2111](https://github.com/curationexperts/laevigata/pull/2111) ([maxkadel](https://github.com/maxkadel))
- Ignore javascript tests from test coverage [\#2110](https://github.com/curationexperts/laevigata/pull/2110) ([maxkadel](https://github.com/maxkadel))
- Add simplecov for formatting and ignoring files for test coverage [\#2106](https://github.com/curationexperts/laevigata/pull/2106) ([maxkadel](https://github.com/maxkadel))
- Remove unused test directory [\#2105](https://github.com/curationexperts/laevigata/pull/2105) ([maxkadel](https://github.com/maxkadel))
- Security fixes [\#2104](https://github.com/curationexperts/laevigata/pull/2104) ([maxkadel](https://github.com/maxkadel))
- Js test suite [\#2103](https://github.com/curationexperts/laevigata/pull/2103) ([maxkadel](https://github.com/maxkadel))
- Upgrading to ruby 2.7 caused some specs with capybara to fail [\#2100](https://github.com/curationexperts/laevigata/pull/2100) ([maxkadel](https://github.com/maxkadel))
- Update README.md [\#2098](https://github.com/curationexperts/laevigata/pull/2098) ([mark-dce](https://github.com/mark-dce))
- Remove scheduled runs of graduation rake task [\#2097](https://github.com/curationexperts/laevigata/pull/2097) ([fnibbit](https://github.com/fnibbit))
- Prepare to change default branch from "master" to "main" [\#2096](https://github.com/curationexperts/laevigata/pull/2096) ([maxkadel](https://github.com/maxkadel))
- Index `embargo\_length` as a singluar, searchable, stored value in Solr [\#2095](https://github.com/curationexperts/laevigata/pull/2095) ([mark-dce](https://github.com/mark-dce))
- Remove duplicate attribute definitions [\#2094](https://github.com/curationexperts/laevigata/pull/2094) ([mark-dce](https://github.com/mark-dce))
- Update VisibilityTranslator to handle various edge cases [\#2089](https://github.com/curationexperts/laevigata/pull/2089) ([mark-dce](https://github.com/mark-dce))
- Update .gitignore to disregard all log and temp files and directories [\#2088](https://github.com/curationexperts/laevigata/pull/2088) ([mark-dce](https://github.com/mark-dce))
- Update README [\#2087](https://github.com/curationexperts/laevigata/pull/2087) ([mark-dce](https://github.com/mark-dce))
- Small updates to readme from starting up from scratch [\#2086](https://github.com/curationexperts/laevigata/pull/2086) ([maxkadel](https://github.com/maxkadel))
- Update readme for ruby 2.7.2 and discontinuation of box.com integration [\#2085](https://github.com/curationexperts/laevigata/pull/2085) ([fnibbit](https://github.com/fnibbit))
- Remove migration-related code [\#2063](https://github.com/curationexperts/laevigata/pull/2063) ([fnibbit](https://github.com/fnibbit))

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

- Ensure file has time to attach before moving on [\#2021](https://github.com/curationexperts/laevigata/pull/2021) ([bess](https://github.com/bess))

**Technical Enhancements:**

- Update release process [\#2024](https://github.com/curationexperts/laevigata/pull/2024) ([bess](https://github.com/bess))
- Moves submission form links to SCO website [\#2023](https://github.com/curationexperts/laevigata/pull/2023) ([rotated8](https://github.com/rotated8))

## [v2.5.3](https://github.com/curationexperts/laevigata/tree/v2.5.3) (2020-02-14)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.5.2...v2.5.3)

## [v2.5.2](https://github.com/curationexperts/laevigata/tree/v2.5.2) (2019-12-30)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.5.1...v2.5.2)

## [v2.5.1](https://github.com/curationexperts/laevigata/tree/v2.5.1) (2019-12-18)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.5.0...v2.5.1)

## [v2.5.0](https://github.com/curationexperts/laevigata/tree/v2.5.0) (2019-12-10)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.8...v2.5.0)

## [v2.4.8](https://github.com/curationexperts/laevigata/tree/v2.4.8) (2019-11-04)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.7...v2.4.8)

## [v2.4.7](https://github.com/curationexperts/laevigata/tree/v2.4.7) (2019-10-24)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.6...v2.4.7)

## [v2.4.6](https://github.com/curationexperts/laevigata/tree/v2.4.6) (2019-09-19)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.5...v2.4.6)

## [v2.4.5](https://github.com/curationexperts/laevigata/tree/v2.4.5) (2019-08-23)

[Full Changelog](https://github.com/curationexperts/laevigata/compare/v2.4.4...v2.4.5)

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
