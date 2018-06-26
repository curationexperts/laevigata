# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schools::Subfield, type: :model do
  let(:school) { Schools::School.new('Rollins School of Public Health') }
  let(:dept) { Schools::Department.new(school, 'Epidemiology') }
  let(:subfield_id) { 'Global Epidemiology - MPH & MSPH' }
  let(:subfield) { described_class.new(school, dept, subfield_id) }

  describe 'init' do
    it 'creates a subfield associated with a department and school' do
      expect(subfield.school).to eq school
      expect(subfield.department).to eq dept
      expect(subfield.label).to eq 'Global Epidemiology - MPH & MSPH'
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

  describe '#admin_set' do
    context 'when admin set is determined at school level' do
      let(:school_id) { 'Laney Graduate School' }
      let(:school) { Schools::School.new(school_id) }
      let(:dept) { Schools::Department.new(school, 'Biostatistics') }
      let(:subfield_id) { 'Global Environmental Health - MPH' }

      before { AdminSet.delete_all }
      let!(:as_laney) { FactoryBot.create(:admin_set, title: [school_id]) }
      let!(:as_other) { FactoryBot.create(:admin_set, title: [subfield_id]) }

      it 'returns nil' do
        expect(AdminSet.count).to eq 2
        expect(school.admin_set.title).to eq [school.id]
        expect(subfield.admin_set).to eq nil
      end
    end

    context 'when admin set is determined at department level' do
      let(:dept) { Schools::Department.new(school, 'Biostatistics') }
      let(:subfield_id) { 'Public Health Informatics' }

      before { AdminSet.delete_all }
      let!(:as_dept) { FactoryBot.create(:admin_set, title: [dept.id]) }
      let!(:as_sub) { FactoryBot.create(:admin_set, title: [subfield_id]) }

      it 'returns nil' do
        expect(AdminSet.count).to eq 2
        expect(dept.admin_set.title).to eq [dept.id]
        expect(subfield.admin_set).to eq nil
      end
    end

    context 'when admin set is determined at subfield level' do
      let(:subfield_id) { 'Global Environmental Health - MPH' }

      before { AdminSet.delete_all }
      let!(:as_subfield) { FactoryBot.create(:admin_set, title: [subfield_id]) }
      let!(:as_other) { FactoryBot.create(:admin_set, title: ['some other admin set']) }

      it 'returns the AdminSet for this subfield' do
        expect(AdminSet.count).to eq 2
        expect(school.admin_set).to eq nil
        expect(dept.admin_set).to eq nil
        expect(subfield.admin_set.title).to eq [subfield_id]
      end
    end
  end
end
