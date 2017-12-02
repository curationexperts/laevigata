require 'rails_helper'
describe ContentEventJob do
  let(:depositor) { FactoryBot.create(:user) }
  it "does not fail when logging an event" do
    expect { FileSetAttachedEventJob.new.log_user_event(depositor) }.not_to raise_exception
  end
end
