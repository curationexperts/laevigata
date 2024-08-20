# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schools::School, type: :model do
  let(:school) { described_class.new(id) }
  let(:id) { 'Candler School of Theology' }

  describe '::active_elements' do
    subject { described_class.active_elements }
    let(:school_labels) { subject.map { |school| school[:label] } }

    it 'finds the QA terms for all the active schools' do
      expect(school_labels).to eq [
        'Candler School of Theology',
        'Emory College',
        'Laney Graduate School',
        'Nell Hodgson Woodruff School of Nursing',
        'Rollins School of Public Health'
      ]
    end
  end

  describe 'init' do
    it 'loads the correct school' do
      expect(school.label).to eq 'Candler School of Theology'
    end

    context 'with a bad id' do
      let(:id) { 'not a real school id' }

      it 'doesnt raise an error' do
        expect(school.label).to eq nil
        expect(school.departments).to eq []
      end
    end
  end

  describe '#departments' do
    subject(:depts) { school.departments }

    let(:id) { 'Rollins School of Public Health' }
    let(:dept_id) { 'Biostatistics' }
    let(:bio_dept) { depts.select { |dept| dept.id == dept_id }.first }

    it 'returns the departments for this school' do
      expect(depts.length).to eq 7
      expect(bio_dept.label).to eq 'Biostatistics and Bioinformatics'
    end
  end

  describe '#admin_set' do
    let(:id_candler) { 'Candler School of Theology' }
    let(:id_rollins) { 'Rollins School of Public Health' }
    let(:candler) { described_class.new(id_candler) }
    let(:rollins) { described_class.new(id_rollins) }

    before { AdminSet.delete_all }
    let!(:as_candler) { FactoryBot.create(:admin_set, title: [id_candler]) }
    let!(:as_other) { FactoryBot.create(:admin_set, title: ['some other admin set']) }

    # Candler has an associated AdminSet, but Rollins
    # doesn't because AdminSets for Rollins are
    # determined by department rather than by school.
    it 'returns an AdminSet if there is one at the school level' do
      expect(AdminSet.count).to eq 2
      expect(candler.admin_set.title).to eq [id_candler]
      expect(rollins.admin_set).to eq nil
    end
  end
end
