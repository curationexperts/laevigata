class EtdEmbargoService < Hyrax::EmbargoService
  class << self
      def assets_under_embargo
        presenters(EtdEmbargoSearchBuilder.new(self))
      end
  end
end
