# frozen_string_literal: true

# This is a shim class that is meant to represent a
# file that the student wants to upload from Box.
# Since we are fetching the file in a background job,
# the actual file won't yet be available for the
# UploadsController or the edit form, so this class
# will provide the missing methods that are called by
# carrierwave or hyrax when they are trying to
# interact with the file.

class FakeUploadedFile < StringIO
  # The name of the file the student wants to upload from Box
  attr_accessor :original_filename
end
