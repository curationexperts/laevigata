require 'rails_helper'

RSpec.describe InProgressEtdsController do
  render_views
  if Flipflop.new_ui?
    describe 'POST create' do
      it 'persists a new InProgressEtd' do
        post :create, params: { in_progress_etd: { name: 'Maud Gonne' } }

        expect(InProgressEtd.all.count).to eq 1
      end

      it 'persists a new InProgressEtd with all of its attributes' do
        post :create, params: { in_progress_etd: { name: 'Maud Gonne', email: 'maud@sinnfein.org', graduation_date: '1916', submission_type: 'Honors Thesis' } }

        expect(InProgressEtd.last.name).to eq('Maud Gonne')
        expect(InProgressEtd.last.email).to eq('maud@sinnfein.org')
        expect(InProgressEtd.last.graduation_date).to eq('1916')
        expect(InProgressEtd.last.submission_type).to eq('Honors Thesis')
      end
    end

    describe 'GET Show' do
      let(:in_progress_etd) { FactoryBot.create(:in_progress_etd) }
      it 'shows an InProgressEtd' do
        get :show, params: { id: in_progress_etd.id }

        expect(response.status).to eq(200)
      end
    end

    describe 'GET Edit' do
      let(:in_progress_etd) { FactoryBot.create(:in_progress_etd) }

      it 'displays the in_progress_etd edit form' do
        get :edit, params: { id: in_progress_etd.id }
      end
    end

    describe 'PUT #Create - Updates' do
      it 'updates the in_progress_etd attributes' do
        put :create, params: { in_progress_etd: { name: 'Frida Kahlo', email: 'frida@blue_house.mx', graduation_date: '1936', submission_type: 'PhD' } }

        expect(InProgressEtd.last.name).to eq('Frida Kahlo')
        expect(InProgressEtd.last.email).to eq('frida@blue_house.mx')
        expect(InProgressEtd.last.graduation_date).to eq('1936')
        expect(InProgressEtd.last.submission_type).to eq('PhD')
      end
    end

    describe 'PATCH #Update - Updates' do
      let(:in_progress_etd) { FactoryBot.create(:in_progress_etd) }
      it 'updates the in_progress_etd attributes' do
        patch :update, params: { id: in_progress_etd.id, in_progress_etd: { name: 'Tina Modetti', email: 'tina@blue_house.mx', graduation_date: '1926', submission_type: 'Never' } }

        expect(InProgressEtd.last.name).to eq('Tina Modetti')
        expect(InProgressEtd.last.email).to eq('tina@blue_house.mx')
        expect(InProgressEtd.last.graduation_date).to eq('1926')
        expect(InProgressEtd.last.submission_type).to eq('Never')
      end
    end
  end
end
