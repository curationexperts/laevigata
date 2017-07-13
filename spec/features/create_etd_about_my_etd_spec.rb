# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

def tinymce_fill_in(id, val)
  # wait until the TinyMCE editor instance is ready. This is required for cases
  # where the editor is loaded via XHR.
  # sleep 0.5 until
  page.evaluate_script("tinyMCE.get('#{id}') !== null")

  js = "tinyMCE.get('#{id}').setContent('#{val}')"
  page.execute_script(js)
end

RSpec.feature 'Create an Etd: About My Etd' do
  let(:user) { create :user }

  context 'a logged in user' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    scenario "'about my etd' has all its inputs" do
      click_on("About My ETD")
      expect(page).to have_css('li#required-my-etd')
      expect(page).to have_css('#about_my_etd input#etd_title')
      expect(page).to have_css('#about_my_etd select#etd_language')
      expect(page).to have_css('#about_my_etd textarea#etd_abstract')
      expect(page).to have_css('#about_my_etd textarea#etd_table_of_contents')
      expect(page).to have_css('#about_my_etd select#etd_research_field')
      expect(page).to have_css('#about_my_etd input#etd_keyword')
      expect(page).to have_css('#about_my_etd input#etd_copyright_question_one_true')
      expect(page).to have_css('#about_my_etd input#etd_copyright_question_one_false')
      expect(page).to have_css('#about_my_etd input#etd_copyright_question_two_true')
      expect(page).to have_css('#about_my_etd input#etd_copyright_question_two_false')
      expect(page).to have_css('#about_my_etd input#etd_copyright_question_three_true')
      expect(page).to have_css('#about_my_etd input#etd_copyright_question_three_false')
    end

    scenario "can save 'about my etd'", js: true do
      click_on("About My ETD")
      fill_in 'Title', with: 'Middlemarch'
      select("French", from: "Language")
      tinymce_fill_in('etd_abstract', 'Literature from the US')
      tinymce_fill_in('etd_table_of_contents', 'Chapter One')
      select 'Aeronomy', from: 'Research Field'
      fill_in 'Keyword', with: "Courtship"
      click_on('about_my_etd_data')
      expect(page).to have_content 'Successfully saved About My Etd'
      expect(page).to have_css 'li#required-my-etd.complete'
    end

    scenario "manages limit of 3 research fields", js: true do
      click_on("About My ETD")
      expect(page).to have_content('
Select one primary research field and add up to two additional research fields')

      click_on("Add another Research Field")
      click_on("Add another Research Field")

      expect(page).not_to have_css('.etd_research_field button.add')

      first('.etd_research_field button.remove').click
      first('.etd_research_field button.remove').click

      expect(page).to have_css('.etd_research_field button.add')
    end
  end
end
