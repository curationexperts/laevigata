RSpec::Matchers.define :become_truthy do |event_name|
  supports_block_expectations

  match do |block|
    begin
      Timeout.timeout(Capybara.default_max_wait_time) do
        sleep(0.05) until value = block.call
        value
      end
    rescue TimeoutError
      false
    end
  end
end