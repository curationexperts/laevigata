module Importer
  class AsynchronousRecordImporter < Darlingtonia::RecordImporter
    ##
    # @param error_stream [#<<]
    def initialize(error_stream: Importer::SerializableStream.new(ActiveJob::Base.logger),
                   info_stream:  Importer::SerializableStream.new(ActiveJob::Base.logger))
      self.error_stream = error_stream
      self.info_stream  = info_stream
    end

    ##
    # @param record [InputRecord]
    #
    # @return [void]
    def import(record:)
      MigrationImportJob.perform_later(record.pid,
                                       record.mapper.source_host,
                                       error_stream,
                                       info_stream)
    end
  end
end
