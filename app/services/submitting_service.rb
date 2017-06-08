# services/submitting_service.rb
class SubmittingService < Hyrax::QaSelectService
  def initialize
    super('submitting_type')
  end
end
