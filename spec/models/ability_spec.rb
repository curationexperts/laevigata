# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject(:current_ability) { described_class.new(current_user) }

  let(:student) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }

  describe 'a student' do
    let(:current_user) { student }

    let(:my_ipe) { InProgressEtd.new(user_ppid: current_user.ppid) }

    let(:another_user) { FactoryBot.create(:user) }
    let(:someone_elses_ipe) { InProgressEtd.new(user_ppid: another_user.ppid) }

    it do
      is_expected.to     be_able_to(:create, InProgressEtd)
      is_expected.to     be_able_to(:update, my_ipe)
      is_expected.to_not be_able_to(:update, someone_elses_ipe)
    end

    context "permission to edit someone else's ETD" do
      let(:someone_elses_etd) { FactoryBot.create(:etd, user: another_user, edit_users: [student.user_key]) }
      let(:someone_elses_ipe) { InProgressEtd.new(user_ppid: another_user.ppid, etd_id: someone_elses_etd.id) }

      it 'can edit InProgressEtd' do
        expect(current_ability.can?(:update, someone_elses_ipe)).to eq true
      end
    end

    context "can't find solr document" do
      let(:bad_id) { "this ID doesn't exist" }
      let(:someone_elses_ipe) { InProgressEtd.new(user_ppid: another_user.ppid, etd_id: bad_id) }

      it 'denies permission' do
        expect(current_ability.can?(:update, someone_elses_ipe)).to eq false
      end
    end
  end # a student
end
