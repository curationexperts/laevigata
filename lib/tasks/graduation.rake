namespace :emory do
  desc "Check for new graduates."
  task :graduation do
    puts "Running GraduationService with file #{ENV['REGISTRAR_DATA_PATH']}"
    GraduationService.run
  end
end
