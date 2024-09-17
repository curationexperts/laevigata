require 'rails_helper'

RSpec.describe Hyrax::LaevigataAuthorityService do
  subject(:select_service) { described_class.new('graduation_dates') }

  describe '.for' do
    it 'raises an error if no arguments are passed' do
      expect { described_class.for }.to raise_error ArgumentError
    end

    it 'raises an error if both a school and department are passed' do
      expect { described_class.for(school: 'Moomin College', department: 'Moomin Studies') }
        .to raise_error ArgumentError, /school: Moomin College; department: Moomin Studies/
    end

    context 'with :school' do
      it 'gives a department service when a school is given' do
        service = described_class.for(school: 'Emory College')
        expect(service.authority.subauthority).to eq 'emory_programs'
      end

      it 'gives a different department service when another school is given' do
        service = described_class.for(school: 'Laney Graduate School')
        expect(service.authority.subauthority).to eq 'laney_programs'
      end

      it 'returns nil when and invalid school is passed' do
        expect(described_class.for(school: 'Moomin College')).to be_nil
      end
    end

    context 'with :department' do
      it 'has subfields for business' do
        service = described_class.for(department: 'Business')
        expect(service.select_all_options).to include(['Finance', 'Finance'])
      end

      it 'has subfields for religion' do
        service = described_class.for(department: 'Religion')
        expect(service.select_all_options).to include(['Ethics and Society', 'Ethics and Society'])
      end

      it 'has subfields for environmental studies' do
        service = described_class.for(department: 'Environmental Studies')
        expect(service.select_all_options).to include(['Environmental Health Epidemiology - MPH & MSPH', 'Environmental Health Epidemiology - MPH & MSPH'])
      end

      it 'has subfields for EMPH' do
        service = described_class.for(department: 'Executive Masters of Public Health - MPH')
        expect(service.select_all_options).to include(['Applied Public Health Informatics', 'Applied Public Health Informatics'])
      end

      it 'returns nil when an invalid department is passed' do
        expect(described_class.for(department: 'Moomin Studies')).to be_nil
      end
    end
  end

  describe '#include_current_value' do
    let(:render_opts) { [] }
    let(:html_opts)   { { class: 'moomin' } }
    let(:active_value) { select_service.select_active_options.first.first }

    it 'adds an inactive current value' do
      expect(select_service.include_current_value('2009', :idx, render_opts, html_opts))
        .to eq [[['2009', '2009']], { class: 'moomin force-select' }]
    end

    it 'does not add an empty/missing value' do
      expect(select_service.include_current_value('', :idx, render_opts, html_opts))
        .to eq [render_opts, html_opts]
    end

    it 'does not add an active current value' do
      expect(select_service.include_current_value(active_value, :idx, render_opts.dup, html_opts.dup))
        .to eq [render_opts, html_opts]
    end
  end
end
