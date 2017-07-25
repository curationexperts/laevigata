desc "Check for new graduates."
task :graduation do
  GraduationService.check_for_new_graduates
end
