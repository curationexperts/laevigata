# Generated via `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Create an Etd' do
  let(:user) { create :user }

  context 'a logged in user' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    scenario "View Etd Tabs", js: true do
      expect(page).to have_selector("[data-toggle='tab']", text: "About Me")
      expect(page).to have_selector("[data-toggle='tab']", text: "My ETD")
      expect(page).to have_selector("[data-toggle='tab']", text: "My PDF")
      expect(page).to have_selector("[data-toggle='tab']", text: "Supplemental Files")
      expect(page).to have_selector("[data-toggle='tab']", text: "Embargoes")
      expect(page).to have_selector("[data-toggle='tab']", text: "Review & Submit")
    end

    scenario "Submission Checklist contains all ETD requirement checkboxes" do
      expect(page).to have_selector("li#required-about-me")
      expect(page).to have_selector("li#required-my-etd")
      expect(page).to have_selector("li#required-files")
      expect(page).to have_selector("li#required-supplemental-files")
      expect(page).to have_selector("li#required-embargoes")
    end
  end

  context 'a logged in (non-admin) user' do
    let(:title) { 'A great thesis by Frodo' }
    let(:workflow_setup) { WorkflowSetup.new("#{fixture_path}/config/emory/superusers.yml", "#{fixture_path}/config/emory/ec_admin_sets.yml", "/dev/null") }

    before do
      # Don't run background jobs during the spec
      allow(ActiveJob::Base).to receive_messages(perform_later: nil, perform_now: nil)

      # Create AdminSet and Workflow
      ActiveFedora::Cleaner.clean!
      workflow_setup.setup

      login_as user
      visit new_hyrax_etd_path
    end

    scenario "Create a new ETD", js: true do
      pending
      # Fill in 'About Me' tab
      fill_in 'Student Name', with: 'Johnson, Frodo'
      select 'Spring 2018', from: 'Graduation date'
      fill_in 'Post graduation email', with: 'frodo@example.com'
      select 'Emory College', from: 'School'
      select 'Religion', from: 'Department'
      select 'Ethics and Society', from: 'Sub Field'
      select 'CDC', from: 'Partnering agency'
      select 'PhD', from: 'Degree'
      select 'Dissertation', from: 'I am submitting my'
      # TODO: Committee Chair
      # TODO: Committee Member
      click_on('Save About Me')

      # Fill in 'My ETD' tab
      click_on('My ETD')
      fill_in 'Title', with: title
      # TODO: fill in all fields
      click_on('Save My ETD')

      # TODO: Attach primary PDF
      # TODO: Attach supplementary file(s)
      # TODO: Create an embargo

      # Save the form
      check('agreement')
      save_and_wait = -> { click_button "Save"; wait_for_ajax(10) }
      expect(save_and_wait).to change { Etd.count }.by(1)
                           .and change { FileSet.count }.by(0)

      # Find our newly-created ETD
      etds = Etd.where(title_tesim: title)
      expect(etds.length).to eq 1 # Make sure only 1 ETD in array
      etd = etds.first

      # Meanwhile, an admin user approves our ETD
      expect(page).to have_content "The work is not currently available because it has not yet completed the approval process"
      expect(etd.to_sipity_entity.workflow_state_name).to eq 'pending_approval'
      approve_etd(etd, workflow_setup.superusers.first)
      expect(etd.to_sipity_entity.workflow_state_name).to eq 'approved'

      # After it is approved, we can view the ETD
      visit hyrax_etd_path(etd)

      # Verify metadata from 'About Me' tab
      expect(page).to have_content 'Johnson, Frodo'
      expect(page).to have_content 'Spring 2018'
      # TODO: expect(etd.post_graduation_email).to eq ['frodo@example.com']
      expect(page).to have_content 'School Emory College'
      expect(page).to have_content 'Department Religion'
      expect(page).to have_content 'Subfield / Discipline Ethics and Society'
      expect(page).to have_content 'Partnering Agencies CDC'
      expect(page).to have_content 'Degree Ph.D.'
      expect(page).to have_content 'Submission Dissertation'
      # TODO: Test committee chair & members names and affiliations

      # Verify metadata from 'My ETD' tab
      expect(page).to have_content title
    end
  end

  context 'a logged out user' do
    scenario "cannot get to submit page from 'share your work' link" do
      visit(root_url)
      click_link("Share Your Work")

      expect(current_url).not_to start_with new_hyrax_etd_url
      expect(current_url).to eq(new_user_session_url)
    end

    scenario "cannot browse to submit page" do
      visit(new_hyrax_etd_url)

      expect(page).to have_content("You are not authorized to access this page.")
      expect(current_url).to start_with(new_user_session_url)
    end
  end
end
