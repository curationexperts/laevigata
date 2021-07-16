Flipflop.configure do
  feature :read_only,
          default: false,
          description: "Put the system into read-only mode. Deposits, edits, approvals and anything that makes a change to the data will be disabled. For use in "

  feature :versions_link,
          default: false,
          description: "Display the 'Versions' link under the 'Actions' menu"
end
