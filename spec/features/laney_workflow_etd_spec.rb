# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'
require 'active_fedora/cleaner'
require 'workflow_setup'
include Warden::Test::Helpers

RSpec.feature 'Create a Laney ETD' do
  let(:user) { create :user }
  let(:w) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/", "#{::Rails.root}/config/emory/schools.yml", "/dev/null") }
  let(:superuser) { w.superusers.first }
  context 'a logged in user' do
    before do
      ActiveFedora::Cleaner.clean!
      w.setup
      login_as user
    end

    scenario "Submit a thesis" do
      visit(root_url)
      click_link("Share Your Work")
      expect(current_url).to start_with new_hyrax_etd_url
      expect(page).to have_css('input#etd_title.required')
      expect(page).not_to have_css('input#etd_title.multi_value')
      expect(page).to have_css('input#etd_creator.required')
      expect(page).not_to have_css('input#etd_creator.multi_value')
      title = "Surrealism #{rand}"
      fill_in 'Title', with: title
      fill_in 'Creator', with: 'Coppola, Joey'
      fill_in 'Keyword', with: 'Surrealism'
      # Department is not required, by default it is hidden as an additional field
      click_link("Additional fields")
      fill_in "Department", with: "Religion"
      fill_in "School", with: "Laney Graduate School"
      select('All rights reserved', from: 'Rights')
      choose('open')
      check('agreement')
      click_on('Files')
      attach_file('files[]', "#{fixture_path}/joey/joey_thesis.pdf")
      click_on('Save')
      expect(page).to have_content title
      expect(page).to have_content 'Pending review'

      # Check workflow permissions for depositing user
      etd = Etd.where(title: [title]).first
      available_workflow_actions = Hyrax::Workflow::PermissionQuery.scope_permitted_workflow_actions_available_for_current_state(user: user, entity: etd.to_sipity_entity).pluck(:name)
      expect(available_workflow_actions.include?("approve")).to eq false
      expect(available_workflow_actions.include?("request_changes")).to eq false
      expect(available_workflow_actions.include?("comment_only")).to eq false

      # logout

      # login_as superuser
      # etd = Etd.where(title: ["Surrealism and Foucaultist power relations"]).first
      # visit("/concern/etds/#{etd.id}")
      # expect(page).to have_content "Pending review"
    end
  end
end
