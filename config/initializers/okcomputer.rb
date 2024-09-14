require 'honeybadger'

class SmtpCheck < OkComputer::Check
  def check
    smtp = Net::SMTP.new ENV['ACTION_MAILER_SMTP_ADDRESS'], ENV['ACTION_MAILER_PORT']
    smtp.enable_starttls
    smtp.start('aws.emory.edu', ENV['ACTION_MAILER_USER_NAME'], ENV['ACTION_MAILER_PASSWORD'], :plain) do |s|
      mark_message "SMTP connection working"
    end
  rescue => exception
    Honeybadger.notify(exception)
    mark_failure
    mark_message "Cannot connect to SMTP"
  end
end

class EtdLoadCheck < OkComputer::Check
  def check
    raise "We can't find an Etd object in the repository" if Etd.first.nil?
  rescue => exception
    Honeybadger.notify(exception)
    mark_failure
    mark_message exception.message
  end
end

OkComputer::Registry.register "etd_load", EtdLoadCheck.new
OkComputer::Registry.register "smtp",     SmtpCheck.new

# Measure the latency of a sidekiq queue against some acceptable threshold measured in seconds
# Latency == the difference between when the oldest job was pushed onto the queue versus the current time.
# In other words, we want ingest jobs to run in < 5 minutes, and derivatives jobs to run in < 15 minutes.
OkComputer::Registry.register 'ingest_queue', OkComputer::SidekiqLatencyCheck.new(:ingest, 300)
OkComputer::Registry.register 'derivatives_queue', OkComputer::SidekiqLatencyCheck.new(:derivatives, 900)
OkComputer::Registry.register 'default_queue', OkComputer::SidekiqLatencyCheck.new(Hyrax.config.ingest_queue_name.to_sym, 300)
OkComputer::Registry.register 'batch_queue', OkComputer::SidekiqLatencyCheck.new(:batch, 300)
