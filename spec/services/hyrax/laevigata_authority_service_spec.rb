require 'rails_helper'

RSpec.describe Hyrax::LaevigataAuthorityService do
  subject(:select_service) { described_class.new('graduation_dates') }

  describe '.for' do
    it 'raises an error if no arguments are passed' do
      expect { described_class.for }.to raise_error ArgumentError
    end

    it 'raises an error if both a school and department are passed' do
      expect { described_class.for(school: 'Moomin College', department: 'Moomin Studies') }
        .to raise_error ArgumentError
    end

    it 'gives a department service when a school is given' do
      expect(described_class.for(school: 'Emory'))
        .to be_a Hyrax::EmoryService
    end

    it 'gives a different department service when another school is given' do
      expect(described_class.for(school: 'Laney School'))
        .to be_a Hyrax::LaneyService
    end

    it 'is nil an invalid school is given' do
      expect(described_class.for(school: 'Moomin College')).to be_nil
    end

    it 'gives a subfield service when a department is given' do
      expect(described_class.for(department: 'Business'))
        .to be_a Hyrax::BusinessService
    end

    it 'gives a different subfield service when another department is given' do
      expect(described_class.for(department: 'Religion or something'))
        .to be_a Hyrax::ReligionService
    end

    it 'is nil an invalid department is given' do
      expect(described_class.for(school: 'Moomin Studies')).to be_nil
    end

    describe 'regression tests' do
      it 'has an enviornmental service' do
        expect(described_class.for(department: 'Environmental Studies'))
          .to be_a Hyrax::EnvironmentalService
      end

      it 'has an EMPH service' do
        expect(described_class.for(department: 'Executive Masters of Public Health - MPH'))
          .to be_a Hyrax::ExecutiveService
      end
    end
  end

  describe '#include_current_value' do
    let(:render_opts) { [] }
    let(:html_opts)   { { class: 'moomin' } }

    it 'adds an inactive current value' do
      expect(select_service.include_current_value('2009', :idx, render_opts, html_opts))
        .to eq [[['2009', '2009']], { class: 'moomin force-select' }]
    end

    it 'does not add an empty/missing value' do
      expect(select_service.include_current_value('', :idx, render_opts, html_opts))
        .to eq [render_opts, html_opts]
    end

    it 'does not add an active current value' do
      expect(select_service.include_current_value('Spring 2020', :idx, render_opts.dup, html_opts.dup))
        .to eq [render_opts, html_opts]
    end
  end
end
