module GraduationHelper
  # Calculates the post-graduation embargo release date
  # @param graduation_date [Date] - the date a degree is awarded
  # @param requested_embargo [String] - the requested embargo length /\d+ [months|years]/
  def self.embargo_length_to_embargo_release_date(graduation_date, requested_embargo)
    if requested_embargo == InProgressEtd::NO_EMBARGO || requested_embargo.blank?
      # No post-graduation embargo to apply
      Rails.logger.warn "Treating empty requested_embargo as 'None'" if requested_embargo.blank?
      graduation_date
    else
      # Calculate embargo expiration date
      number, units = requested_embargo.split(" ")
      raise ArgumentError, "Unexpected embargo length '#{requested_embargo}'" unless valid_length(number, units)
      graduation_date = Date.parse(graduation_date) if graduation_date.class == String
      graduation_date + Integer(number).send(units.to_sym)
    end
  end

  # Ensure valid values like "6 months", "2 months", "6 years"
  def self.valid_length(number, units)
    valid_quantity = number.to_i > 0
    valid_units = ['months', 'year', 'years'].include?(units)
    valid_quantity && valid_units
  end
end
