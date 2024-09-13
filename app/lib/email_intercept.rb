require 'yaml'

class EmailIntercept
  # Filter email prior to sending
  # Currently only filters out messages to dummy accounts to prevent bounces
  def self.delivering_email(message)
    message.to.each do |recipient|
      message.perform_deliveries = false if recipient == 'tezprox@emory.edu'
    end
  end
end
