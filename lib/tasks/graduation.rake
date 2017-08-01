namespace :emory do
  desc "Check for new graduates."
  task :graduation do
    GraduationService.run
  end
end
