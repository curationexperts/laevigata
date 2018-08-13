# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InProgressEtdsController, type: :controller do
  before(:all) do
    new_ui = Rails.application.config_for(:new_ui).fetch('enabled', false)
    skip("These tests run only when NEW_UI_ENABLED") unless new_ui
  end

  let(:student) { FactoryBot.create(:user) }
  let(:another_user) { FactoryBot.create(:user) }

  let(:ipe) { InProgressEtd.create(user_ppid: student.ppid) }

  context 'logged in as a student' do
    before { sign_in student }

    context 'GET NEW - when the student has no previously saved record' do
      before { InProgressEtd.destroy_all }

      it 'creates a new record' do
        expect {
          get :new
        }.to change { InProgressEtd.count }.by(1)

        expect(assigns[:in_progress_etd].user_ppid).to eq student.ppid
        expect(response).to redirect_to edit_in_progress_etd_path(assigns[:in_progress_etd].id)
      end
    end

    context 'GET NEW - when the student has previously saved a record' do
      before { ipe } # create the record

      it 'finds the existing record' do
        expect {
          get :new
        }.to change { InProgressEtd.count }.by(0)

        expect(response).to redirect_to edit_in_progress_etd_path(ipe)
      end
    end

    describe 'GET EDIT' do
      let(:ipe) { InProgressEtd.create(user_ppid: another_user.ppid, etd_id: etd.id) }

      context 'with permission to edit Etd' do
        let(:etd) { FactoryBot.create(:etd, user: another_user, edit_users: [student.user_key]) }

        it 'displays edit form' do
          get :edit, params: { id: ipe.id }
          expect(response).to render_template(:edit)
        end
      end

      context 'without permission to edit Etd' do
        let(:etd) { FactoryBot.create(:etd, user: another_user) }

        it 'denies access' do
          get :edit, params: { id: ipe.id }
          expect(response.status).to eq 401 # Unauthorized
        end
      end
    end

    describe 'DELETE DESTROY' do
      before { ipe }
      it 'redirects to login' do
        delete :destroy, params: { id: ipe.id }
        expect(InProgressEtd.all.size).to eq(0)
        expect(response).to redirect_to(root_url)
      end
    end

    describe 'PATCH UPDATE' do
      let(:new_title) { ['New Title from Update'] }

      context 'with permission to edit' do
        before do
          patch :update, params: { id: ipe.id, etd: { title: new_title } }
          ipe.reload
        end

        it 'updates the record' do
          expect(JSON.parse(ipe.data)['title']).to eq new_title
        end
      end

      context "maliciously try to edit fields you shouldn't" do
        before do
          patch :update, params: {
            id: ipe.id,
            user_ppid: "try to attack someone else's InProgressEtd",
            etd_id: "try to attack someone else's Etd",
            etd: { title: new_title }
          }
          ipe.reload
        end

        it "doesn't allow student to directly edit etd_id or user_ppid fields" do
          expect(ipe.etd_id).to eq nil
          expect(ipe.user_ppid).to eq student.ppid
        end
      end

      context 'without permission to edit' do
        let(:ipe) { InProgressEtd.create(user_ppid: another_user.ppid) }

        it 'denies access' do
          patch :update, params: { id: ipe.id, in_progress_etd: { title: new_title } }
          expect(response.status).to eq 401 # Unauthorized
        end
      end
    end
  end

  context 'not logged in' do
    describe 'GET NEW' do
      it 'redirects to login' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'GET EDIT' do
      it 'redirects to login' do
        get :edit, params: { id: ipe.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'PATCH UPDATE' do
      it 'redirects to login' do
        patch :update, params: { id: ipe.id, in_progress_etd: { title: ['New Title from Update'] } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'DELETE DESTROY' do
      it 'redirects to login' do
        delete :destroy, params: { id: ipe.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
