require 'rails_helper'

RSpec.describe InProgressEtd, type: :model do
  if Flipflop.new_ui?
    it 'contains basic student data' do
      in_progress_etd = InProgressEtd.create!(name: 'Miranda', email: 'miranda@graduated.org', graduation_date: 'Summer 2020', submission_type: 'Honors Thesis')

      expect(in_progress_etd.attributes).to include('name' => 'Miranda', 'email' => 'miranda@graduated.org', 'graduation_date' => 'Summer 2020', 'submission_type' => 'Honors Thesis')
    end
  end
end
