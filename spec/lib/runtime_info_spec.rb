# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RuntimeInfo do
  describe '.environment' do
    describe 'in AWS environments' do
      let(:response) { nil }

      before do
        allow(described_class).to receive(:ec2?).and_return(true)

        # stub an EC2Metadata object
        metadata_service = instance_double(Aws::EC2Metadata)
        # stub the metadata service
        allow(Aws::EC2Metadata).to receive(:new).and_return(metadata_service)
        # stub metadata responses
        allow(metadata_service).to receive(:get).and_return(response)
      end

      context 'with tag:Environment=prod' do
        let(:response) { 'prod' }
        it 'returns "Production"' do
          expect(described_class.environment).to eq('production')
        end
      end

      context 'with tag:Environment=stage' do
        let(:response) { 'stage' }
        it 'returns "Staging"' do
          expect(described_class.environment).to eq('staging')
        end
      end

      context 'with tag:Environment=qa' do
        let(:response) { 'qa' }
        it 'returns "quality assurance"' do
          expect(described_class.environment).to eq('qa testing')
        end
      end

      context 'with tag:Environment=any other string' do
        let(:response) { 'any_other_string' }
        it 'returns the tag' do
          expect(described_class.environment).to eq('any_other_string')
        end
      end

      context 'with no Environment tag' do
        before do
          # stub an EC2Metadata object
          metadata_service = instance_double(Aws::EC2Metadata)
          # stub the metadata service
          allow(Aws::EC2Metadata).to receive(:new).and_return(metadata_service)
          # stub metadata responses
          allow(metadata_service).to receive(:get).and_raise(Aws::EC2Metadata::MetadataNotFoundError)
        end

        it 'returns the Rails environment' do
          expect(described_class.environment).to match('missing')
        end
      end
    end

    describe 'in local environments' do
      before do
        allow(Rails).to receive(:env).and_return('test')

        # stub an EC2Metadata object
        metadata_service = instance_double(Aws::EC2Metadata)
        # stub the metadata service
        allow(Aws::EC2Metadata).to receive(:new).and_return(metadata_service)
        # speed up failures
        allow(metadata_service).to receive(:get).and_raise(Errno::EHOSTDOWN)
      end

      context 'in test' do
        it 'returns the Rails environment' do
          expect(described_class.environment).to eq('test')
        end
      end

      context 'in development' do
        before do
          allow(Rails).to receive(:env).and_return('development')
        end

        it 'returns the Rails environment' do
          expect(described_class.environment).to eq('development')
        end
      end
    end

    describe '.badge' do
      before do
        described_class.instance_variable_set(:@badge, nil)
      end

      context 'in EC2 production environments' do
        before do
          allow(described_class).to receive(:ec2?).and_return(true)
          allow(described_class).to receive(:environment_tag).and_return('prod')
        end

        it 'returns a hidden div' do
          expect(described_class.badge).to match(/class="hidden"/)
        end
      end

      context 'in non-EC2 environments' do
        it 'returns the rails environment' do
          expect(described_class.badge).to match(/>Test</)
        end

        it 'is not hidden' do
          expect(described_class.badge).not_to match(/class="hidden"/)
        end
      end

      context 'in other environments' do
        before do
          allow(described_class).to receive(:environment_tag).and_return('testing qa3')
          allow(described_class).to receive(:ec2?).and_return(true)
        end

        it 'returns a div tag with the expected ID' do
          expect(described_class.badge).to match('<div id="environment_badge"')
        end

        it 'capitalizes the envioronment name' do
          expect(described_class.badge).to match('Testing Qa3')
        end
      end
    end
  end
end
