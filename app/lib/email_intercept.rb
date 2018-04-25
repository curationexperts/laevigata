class EmailIntercept
  def self.delivering_email(message)
    do_not_send = [
      "bnash3@emory.edu",
      "tezprox@emory.edu"
    ]
    message.to.each do |recipient|
      message.perform_deliveries = false if do_not_send.include? recipient
    end
  end
end
