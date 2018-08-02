# frozen_string_literal: true

class FetchRemoteFileJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # Fetch the remote file from Box and store it in a
  # local file on the hard drive.
  #
  # We need to do this if we don't yet have an Etd
  # record to attach the file to.  Box's download URLs
  # expire quickly, so we keep a local temp file until
  # we are ready to attach the file to the Etd.
  #
  # @param uploaded_file_id [Integer, String] The ID for a Hyrax::UploadedFile record.
  # @param remote_url [String] The URL to fetch the file from Box.
  def perform(uploaded_file_id, remote_url)
    uploaded_file = ::Hyrax::UploadedFile.find uploaded_file_id

    # Download & save the file
    uploaded_file.remote_file_url = remote_url
    uploaded_file.save!
  end
end
