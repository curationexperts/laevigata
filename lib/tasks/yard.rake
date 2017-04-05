require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', 'app/**/*.rb', 'config/initializers/*.rb']
  # Uncomment if you want to print out which classes and methods are undocumented
  # t.stats_options = ['--list-undoc']
end
