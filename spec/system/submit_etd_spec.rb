# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Logged in student can submit an ETD", :clean, type: :system, js: true do
  let(:student) { create :user }
  let(:pdf) { Rails.root.join('spec', 'fixtures', 'joey', 'joey_thesis.pdf') }

  context 'a logged in user' do
    before do
      login_as student
    end

    scenario "submitting a new ETD", js: true do
      visit("/concern/etds/new")
      expect(page).to have_content('School')
      visit("/concern/etds/new") # refresh the page
      expect(page).to have_content('School')

      # About Me
      expect(page).to have_content('Post-Graduation Email')
      expect(page).to have_content('Please provide a post-graduation email address')

      fill_in 'Student Name', with: FFaker::Name.name
      select 'Emory College', from: 'School'
      first_active_semester = find('#graduation-date > option:nth-child(2)').text
      select first_active_semester, from: 'Graduation Date'
      fill_in 'Post-Graduation Email', with: FFaker::Internet.email
      click_on 'Save and Continue'

      # My Program
      expect(page).to have_content('Department')
      select 'Environmental Sciences', from: 'Department'
      select 'MA', from: 'Degree'
      select 'Honors Thesis', from: 'Submission Type'
      click_on 'Save and Continue'

      # My Advisor
      expect(page).to have_content('Add a Committee Chair')
      click_on 'Add a Committee Chair'
      fill_in 'etd[committee_chair_attributes][0][name][]', with: FFaker::Name.name
      click_on 'Add a Committee Member'
      fill_in 'etd[committee_members_attributes][0][name][]', with: FFaker::Name.name
      click_on 'Add a Committee Chair'
      fill_in 'etd[committee_chair_attributes][1][name][]', with: FFaker::Name.name
      click_on 'Add a Committee Member'
      fill_in 'etd[committee_members_attributes][1][name][]', with: FFaker::Name.name
      click_on 'Save and Continue'

      # My ETD
      expect(page).to have_content('Title')
      fill_in 'Title', with: FFaker::Book.title
      select 'English', from: 'Language'

      first('div[contenteditable="true"].ql-editor').send_keys FFaker::CheesyLingo.paragraph
      find(:xpath, '//*[@id="vue_form"]/div[4]/div/div[4]/div/div/div/div/div[2]/div[1]').send_keys FFaker::CheesyLingo.paragraph
      click_on 'Save and Continue'
      # Keywords
      expect(page).to have_content('Select a Research Field')
      execute_script("document.querySelector('select:nth-child(3)').selectedIndex = 1")
      click_on 'Add a Keyword'
      find(:xpath, '//*[@id="keywords"]/div/input').send_keys FFaker::CheesyLingo.word
      click_on 'Save and Continue'
      # Using the default copyright questions

      # File Upload
      expect(page).to have_content("My Files")
      page.attach_file('primary_files[]', pdf, make_visible: true)
      expect(page).to have_content 'joey_thesis.pdf'
      click_on 'Save and Continue'

      # Embargoes
      select '6 months', from: 'Requested Embargo Length'
      click_on 'Save and Continue'

      # Review
      find('input[type="checkbox"]').set(true)
      click_on 'Submit Your Thesis or Dissertation'

      expect(page).to have_content 'Submitting'
      expect(page).to have_content 'Environmental Sciences'
    end
  end
end
