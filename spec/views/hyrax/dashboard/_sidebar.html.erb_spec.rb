# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'hyrax/dashboard/_sidebar.html.erb', type: :view do
  # NOTE: this test setup was lifted directly from Hyrax and may be overkill
  let(:user) { FactoryBot.create(:user) }
  let(:read_admin_dashboard) { false }
  let(:manage_any_admin_set) { false }
  let(:review_submissions) { false }
  let(:manage_user) { false }
  let(:update_appearance) { false }
  let(:manage_feature) { false }
  let(:manage_workflow) { false }
  let(:manage_collection_types) { false }
  let(:ability) { double('current ability', can_create_any_work?: false) }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    assign(:user, user)
    allow(view).to receive(:can?).with(:read, :admin_dashboard).and_return(read_admin_dashboard)
    allow(view).to receive(:can?).with(:manage_any, AdminSet).and_return(manage_any_admin_set)
    allow(view).to receive(:can?).with(:review, :submissions).and_return(review_submissions)
    allow(view).to receive(:can?).with(:manage, User).and_return(manage_user)
    allow(view).to receive(:can?).with(:update, :appearance).and_return(update_appearance)
    allow(view).to receive(:can?).with(:manage, Hyrax::Feature).and_return(manage_feature)
    allow(view).to receive(:can?).with(:manage, Sipity::WorkflowResponsibility).and_return(manage_workflow)
    allow(view).to receive(:can?).with(:manage, :collection_types).and_return(manage_collection_types)
    allow(view).to receive(:can?).with(:update, Hydra::AccessControls::Embargo).and_return(false)
    allow(view).to receive(:can?).with(:manage, RegistrarFeed).and_return(true)
    allow(view).to receive(:current_ability).and_return(ability)
  end

  context 'for non-admin user' do
    let(:read_admin_dashboard) { false }
    before { render }

    it "does not link to registrar data" do
      expect(rendered).to have_no_link t('registrar_data_data')
    end
  end

  context 'for admin users' do
    before { render }

    it "gives a link to manage registrar data" do
      expect(rendered).to have_link t('registrar_data')
    end
  end
end
