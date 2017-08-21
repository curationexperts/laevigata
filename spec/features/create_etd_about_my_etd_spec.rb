# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'Create an Etd: My Etd' do
  let(:user) { create :user }

  context 'a logged in user' do
    before do
      login_as user
      visit("/concern/etds/new")
    end

    scenario "'my etd' has all its inputs" do
      click_on("My ETD")
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

    scenario "validates 'my etd'", js: true unless continuous_integration? do
      click_on("My ETD")
      fill_in 'Title', with: 'Middlemarch'
      select("French", from: "Language")
      tinymce_fill_in('etd_abstract', 'Literature from the US')
      tinymce_fill_in('etd_table_of_contents', 'Chapter One')
      select 'Aeronomy', from: 'Research Field'
      fill_in 'Keyword', with: "Courtship"

      click_on('Save My ETD')
      expect(page).to have_css 'li#required-my-etd.complete'
    end

    scenario "manages limit of 3 research fields", js: true unless continuous_integration? do
      click_on("My ETD")
      expect(page).to have_content('Select at least one, but no more than three,' \
      ' research fields that best describe your work. List your primary field first.' \
      ' If you do not see your exact field, pick the closest option.')

      click_on("Add another Research Field")
      click_on("Add another Research Field")

      expect(page).not_to have_css('.etd_research_field button.add')

      first('.etd_research_field button.remove').click
      first('.etd_research_field button.remove').click

      expect(page).to have_css('.etd_research_field button.add')
    end
  end
end
