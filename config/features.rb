Flipflop.configure do
  feature :read_only,
          default: false,
          description: "Put the system into read-only mode. Deposits, edits, approvals and anything that makes a change to the data will be disabled. For use in "

  feature :new_ui,
          default: Rails.application.config_for('new_ui').fetch('enabled', false),
          description: "Developing a simpler, efficient and more modern front end."
end
