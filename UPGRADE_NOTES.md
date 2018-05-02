1.0.5 -> 2.0.1
--------------

Upgraded following the release notes at: https://github.com/samvera/hyrax/releases/tag/v2.0.0

* `IngestFileJob` was removed in 2.0.0. We had to remove internal references to it; ingest queues need to be reconfigured post-upgrade to ensure effective balancing of Sidekiq workers on job types in production.
* BasicMetadata overrides are much harder in Hyrax 2.0. We solved this with a schema application strategy in `mahonia` https://github.com/curationexperts/mahonia/commit/eadb25a30851fecc350cf091102abc73c3b9db0a#diff-f8cfcdbc59e6e04afb8fbb8c7bc66f1d.
