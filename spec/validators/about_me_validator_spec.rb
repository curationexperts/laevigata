require 'rails_helper'

describe AboutMeValidator do
  let(:record) { InProgressEtd.new(data: { 'currentTab': 'About Me', 'creator': '', 'post_graduation_email': 'graduate@somewhere.else' }) }
  it 'returns an empty hash if passed a record without data' do
    expect(record.valid?).to be false
    expect(record.errors.details).to include(school: [{ error: "school is required" }])
  end
end
