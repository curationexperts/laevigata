require 'rails_helper'

RSpec.feature 'contact form page', integration: true do
  scenario 'contact form creation from libwizard', js: true do
    visit "/contact"

    within_frame(find(:css, 'iframe[id^="iframe_"]')) do
      expect(page).to have_title("ETD Help Form")
    end
  end
end
