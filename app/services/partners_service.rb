# services/partners_service.rb
class PartnersService < Hyrax::LaevigataAuthorityService
  def initialize
    super('partnering_agencies')
  end
end
