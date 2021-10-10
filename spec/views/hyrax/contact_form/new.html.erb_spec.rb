require 'rails_helper'

# NOTE: This spec tests the page linked from "ETD Help" in the application footer
# (the "Contact Us" link in the footer connects out to a general SCO help page)
# This spec tests that we are overriding the default Hyrax contact page,
# For speed and isolation reasons, this test does not attempt to run the remote
# javascript from libwizard or validate the remote script's results
RSpec.describe 'hyrax/contact_form/new.html.erb', type: :view do
  it 'overrides the default Hyrax page' do
    render
    # the replacement page should have instructions and a script that loads a form from libwizard
    expect(rendered).to have_css('div.instructions')
    expect(rendered).to match('src="//emory.libwizard.com/form_loader.php')
  end
end
