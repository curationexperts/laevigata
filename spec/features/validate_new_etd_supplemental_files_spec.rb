require 'rails_helper'

RSpec.feature 'Form Validation: "Supplemental Files" tab' do
  let(:student) { create :user }

  context 'a student (non-admin user)' do
    before do
      login_as student
    end

    scenario 'fills in "supplemental files" tab', js: true do
      visit new_hyrax_etd_path

      # When the form first loads, 'supplemental files' tab should be marked as 'incomplete'.
      click_on 'Supplemental Files'
      expect(page).to have_css('li#required-supplemental-files.incomplete')

      # Student uploads a file and fills in some of the metadata fields
      page.attach_file('supplemental_files[]', "#{fixture_path}/magic_warrior_cat.jpg")
      expect(page).to have_css("input[name='etd[supplemental_file_metadata][0]title']")
      fill_in name: 'etd[supplemental_file_metadata][0]title', with: 'supp title'
      fill_in name: 'etd[supplemental_file_metadata][0]description', with: 'supp desc'

      # The tab should still be marked 'incomplete' until the student fills in the last metadata field, and then it should become 'complete'.
      expect(page).to have_css('li#required-supplemental-files.incomplete')
      select 'Image', from: 'etd[supplemental_file_metadata][0]file_type'
      expect(page).to have_css('li#required-supplemental-files.complete')

      # Student deletes the file
      find('button.delete').click
      expect(page).to have_css('li#required-supplemental-files.incomplete')

      # Student checks 'No Supplemental Files'
      check('etd_no_supplemental_files')
      expect(page).to have_css('li#required-supplemental-files.complete')

      # Student unchecks 'No Supplemental Files'
      uncheck('etd_no_supplemental_files')
      expect(page).to have_css('li#required-supplemental-files.incomplete')
    end
  end
end
