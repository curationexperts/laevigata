# services/submitting_service.rb
class SubmittingService < Hyrax::LaevigataAuthorityService
  def initialize
    super('submitting_type')
  end
end
