module Importer
  class LaevigataImporter < Darlingtonia::Parser
    ##
    # @!attribute [rw] source_host
    #   @return [String]
    attr_accessor :source_host

    class << self
      ##
      # Matches all "file" types; we assume anything passed in will be a list
      # of Fedora 3 PIDs.
      def match?(**_opts)
        true
      end
    end

    ##
    # Gives a {Darlingtonia::InputRecord} for each pid in the {#file}.
    def records
      return enum_for(:records) unless block_given?

      file.each_line do |pid|
        yield Darlingtonia::InputRecord
                .from(metadata: pid.strip,
                      mapper:   MigrationMapper.new(source_host: source_host))
      end
    end
  end
end
