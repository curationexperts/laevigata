# services/partners_service.rb
class PartnersService < Hyrax::QaSelectService
  def initialize
    super('partnering_agencies')
  end
end
