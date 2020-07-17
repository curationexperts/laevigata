module GraduationHelper
  # Given a graduation date and an embargo length, calculate the embargo_release_date.
  # This assumes embargo_length values like "6 months", "2 months", "6 years"
  def self.embargo_length_to_embargo_release_date(graduation_date, embargo_length)
    if embargo_length == InProgressEtd::NO_EMBARGO
      graduation_date
    else
      number, units = embargo_length.split(" ")
      graduation_date = Date.parse(graduation_date) if graduation_date.class == String
      graduation_date + Integer(number).send(units.to_sym)
    end
  end
end
