# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schools::Subfield, type: :model do
  let(:school) { Schools::School.new('Rollins School of Public Health') }
  let(:dept) { Schools::Department.new(school, 'Epidemiology') }
  let(:subfield_id) { 'Global Epidemiology - MPH & MSPH' }
  let(:subfield_label) { 'Global Epidemiology' }
  let(:subfield) { described_class.new(school, dept, subfield_id) }

  describe 'init' do
    it 'creates a subfield associated with a department and school' do
      expect(subfield.school).to eq school
      expect(subfield.department).to eq dept
      expect(subfield.label).to eq subfield_label
    end

    context 'with a bad id' do
      let(:subfield_id) { 'not a real subfield id' }

      it 'doesnt raise an error' do
        expect(subfield.school).to eq school
        expect(subfield.department).to eq dept
        expect(subfield.label).to eq nil
      end
    end
  end
end
