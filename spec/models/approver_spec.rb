# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Approver,
               type: :model,
               workflow: { admin_sets_config: 'spec/fixtures/config/emory/admin_sets_small.yml' } do

  let(:superusers) { ['admin_set_owner', 'superman001', 'wonderwoman001', 'tezprox'] }

  describe '::for_admin_set' do
    let(:laney) { AdminSet.where(title_sim: 'Laney Graduate School').first }
    let(:candler) { AdminSet.where(title_sim: 'Candler School of Theology').first }
    let(:epi) { AdminSet.where(title_sim: 'Epidemiology').first }

    let(:laney_approvers) { Approver.for_admin_set(laney) }
    let(:candler_approvers) { Approver.for_admin_set(candler) }
    let(:epi_approvers) { Approver.for_admin_set(epi) }

    it 'finds the users who are approvers for this admin set' do
      expect(laney_approvers.map(&:uid)).to contain_exactly(*superusers, 'laneyadmin', 'laneyadmin2')
      expect(candler_approvers.map(&:uid)).to contain_exactly(*superusers, 'candleradmin', 'candleradmin2')
      expect(epi_approvers.map(&:uid)).to contain_exactly(*superusers, 'epidemiology_admin')
    end
  end
end
