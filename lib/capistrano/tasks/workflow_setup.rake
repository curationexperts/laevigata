namespace :laevigata do
  desc 'Create the AdminSets and import workflow'
  task :workflow_setup do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:seed'
        end
      end
    end
  end
end
