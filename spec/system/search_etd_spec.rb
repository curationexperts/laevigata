require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Search for an ETD', type: :system, integration: true do
  let(:etd) do
    FactoryBot.create(
      :etd,
      creator: ["Janakiramen, Helen"],
      graduation_date: 'Fall 2017',
      school: ["Candler School of Theology"],
      department: ["Robotics"],
      subfield: ["Political Robotics"],
      research_field: ["Artificial Intelligence"],
      date_uploaded: DateTime.current,
      submitting_type: ["Master's Thesis"],
      degree: ["M.S."],
      committee_members_attributes: cm_attrs,
      committee_chair_attributes: cc_attrs,
      keyword: ['key1', 'key2']
    )
  end

  let(:cm_attrs) do
    [{ name: 'Jackson, Henrietta' },
     { name: 'Matsumoto, Yukihiro' }]
  end

  let(:cc_attrs) { [{ name: 'Yurchenko, Alice' }] }

  context 'a logged in user' do
    let(:user) { User.where(ppid: etd.depositor).first }

    before do
      login_as user
    end

    scenario "Search for an ETD" do
      visit("/")
      fill_in "q", with: etd.title.first
      click_button "Go"

      # The metadata that shows in search results
      expect(page).to have_content etd.title.first
      expect(page).to have_content etd.creator.first
      expect(page).to have_content etd.date_uploaded.strftime("%m/%d/%Y")
      expect(page).to have_content etd.research_field[0]
      expect(page).to have_content etd.research_field[1]
      expect(page).to have_content etd.research_field[2]
      expect(page).to have_content etd.department.first

      # Facets
      expect(page).not_to have_xpath("//h3", text: "Student Name")
      expect(page).not_to have_link(etd.creator.first, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "Year")
      expect(page).to have_link(etd.graduation_date, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "School")
      expect(page).to have_link(etd.school.first, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "Department")
      expect(page).to have_link(etd.department.first, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "Degree")
      expect(page).to have_link(etd.degree.first, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "Submission Type")
      expect(page).to have_link(etd.submitting_type.first, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "Research Field")
      expect(page).to have_link(etd.research_field.first, class: "facet_select")
      expect(page).to have_xpath("//h3", text: "Committee")
      expect(page).to have_link('Jackson, Henrietta', class: "facet_select")
      expect(page).to have_link('Matsumoto, Yukihiro', class: "facet_select")
      expect(page).to have_link('Yurchenko, Alice', class: "facet_select")
      expect(page).to have_xpath("//h3", text: "Keyword")
      expect(page).to have_link('key1', class: "facet_select")
      expect(page).to have_link('key2', class: "facet_select")
    end
  end
end
