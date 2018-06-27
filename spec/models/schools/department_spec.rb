# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schools::Department, type: :model do
  let(:school_id) { 'Rollins School of Public Health' }
  let(:school) { Schools::School.new(school_id) }

  let(:dept_id) { 'Biostatistics' }
  let(:dept) { described_class.new(school, dept_id) }

  describe 'init' do
    it 'creates a department associated with that school' do
      expect(dept.school).to eq school
      expect(dept.label).to eq 'Biostatistics and Bioinformatics'
    end

    context 'with a bad id' do
      let(:dept_id) { 'not a real dept id' }

      it 'doesnt raise an error' do
        expect(dept.school).to eq school
        expect(dept.label).to eq nil
      end
    end
  end

  describe '#admin_set' do
    context 'when department name matches an existing AdminSet record, but AdminSet is determined by school, not department' do
      let(:id_laney) { 'Laney Graduate School' }
      let(:laney) { Schools::School.new(id_laney) }
      let(:id_bio) { 'Biostatistics' }
      let(:bio) { described_class.new(laney, id_bio) }

      before { AdminSet.delete_all }
      let!(:as_laney) { FactoryBot.create(:admin_set, title: [id_laney]) }
      let!(:as_bio) { FactoryBot.create(:admin_set, title: [id_bio]) }

      it 'returns no AdminSet for the department because the AdminSet is determined by the school instead' do
        expect(AdminSet.count).to eq 2
        expect(bio.school.admin_set.title).to eq [id_laney]
        expect(bio.admin_set).to eq nil
      end
    end
  end

  describe '#subfields' do
    subject(:subfields) { dept.subfields }

    context 'a department with subfields' do
      it 'returns the subfields for this department' do
        expect(subfields.map(&:label)).to contain_exactly('Biostatistics - MPH & MSPH', 'Public Health Informatics - MSPH')
      end
    end

    context 'a department without subfields' do
      let(:school) { Schools::School.new('Candler School of Theology') }
      let(:dept) { described_class.new(school, 'Divinity') }

      it 'returns empty' do
        expect(subfields).to eq []
      end
    end
  end
end
