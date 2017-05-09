namespace :laevigata do
  namespace :workflow do
    desc 'Set up AdminSets and workflows'
    task :setup do
      Rake::Task["db:seed"].invoke
    end
  end
end
