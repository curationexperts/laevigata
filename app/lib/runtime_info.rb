# frozen_string_literal: true
require 'aws-sdk-core'
require 'aws-sdk-core/ec2_metadata'

include ActionView::Helpers::TagHelper

class RuntimeInfo
  TAG_MAPPER = { 'prod' => 'production', 'stage' => 'staging', 'qa' => 'qa testing' }.freeze

  class << self
    def badge
      @badge ||= tag.div(environment.titleize, id: 'environment_badge', class: display_class)
    end

    def environment
      TAG_MAPPER[environment_tag] || environment_tag || Rails.env
    end

    private

    def display_class
      'hidden' if environment_tag == 'prod'
    end

    def environment_tag
      return nil unless ec2?
      begin
        metadata_client = Aws::EC2Metadata.new
        metadata_client.get('/latest/meta-data/tags/instance/Environment')
      rescue Aws::EC2Metadata::MetadataNotFoundError
        'tag missing'
      rescue Errno::EHOSTDOWN, Net::OpenTimeout, Errno::EHOSTUNREACH
        # just return nil without an exception
      end
    end

    def ec2?
      File.exist?('/sys/devices/virtual/dmi/id/bios_vendor') &&
        File.read('/sys/devices/virtual/dmi/id/bios_vendor').match(/EC2/)
    end
  end
end
