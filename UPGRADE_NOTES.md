1.0.5 -> 2.0.1
--------------

* `IngestFileJob` was removed in 2.0.0. We had to remove internal references to it; ingest queues need to be reconfigured post-upgrade to ensure effective balancing of Sidekiq workers on job types in production.
*
