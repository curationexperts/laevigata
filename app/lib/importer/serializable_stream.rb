module Importer
  ##
  # A Darlingtonia error/info stream that can be serialized for `ActiveJob` with
  # {GlobalId}.
  #
  # @see http://guides.rubyonrails.org/active_job_basics.html#globalid
  class SerializableStream < SimpleDelegator
    include GlobalID::Identification

    ID = 'logger'.freeze

    ##
    # @return [String]
    def id
      ID
    end

    def <<(msg)
      super "[MIGRATION]: #{msg}\n"
    end

    ##
    # @param [String] id
    def self.find(id)
      case id
      when ID
        new(ActiveJob::Base.logger)
      else
        raise "What logger is #{id}???"
      end
    end
  end
end
