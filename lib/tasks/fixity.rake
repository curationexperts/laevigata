namespace :emory do
  desc "Whole repository fixity check"
  task :fixity do
    Hyrax::RepositoryAuditService.audit_everything
  end
end
