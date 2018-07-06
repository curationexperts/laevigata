# frozen_string_literal: true

shared_context 'workflow notification setup', integration: true do
  before(:context) do
    DatabaseCleaner.clean
    ActiveFedora::Cleaner.clean!
    w = WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/candler_admin_sets.yml", "/dev/null")
    w.setup
    RSpec::Mocks.with_temporary_scope do
      @user = FactoryBot.create(:user)
      @etd = FactoryBot.create(:sample_data, depositor: @user.user_key, school: ["Candler School of Theology"])
      ability = ::Ability.new(@user)
      @recipients = { 'to' => [FactoryBot.create(:user), FactoryBot.create(:user)] }
      attributes = {}
      env = Hyrax::Actors::Environment.new(@etd, ability, attributes)
      terminator = Hyrax::Actors::Terminator.new
      middleware = Hyrax::DefaultMiddlewareStack.build_stack.build(terminator)
      middleware.create(env)
      work_global_id = @etd.to_global_id.to_s
      entity = Sipity::Entity.where(proxy_for_global_id: work_global_id).first
      @notification = described_class.new(entity, '', @user, @recipients)
    end
  end
end
