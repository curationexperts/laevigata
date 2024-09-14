Hydra::Works.default_system_virus_scanner = ::ClambyScanner

Clamby.configure(
  check:  false, # only used for development environment
  daemonize: Rails.env.production?,
  error_clamscan_missing: Rails.env.production?,
  error_file_missing: true,
  error_file_virus: false, # we trigger a custom virus error, this setting will cause that to never trigger if true in prod
  fdpass: true
)
