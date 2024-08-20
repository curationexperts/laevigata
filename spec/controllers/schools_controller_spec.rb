# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolsController, type: :controller do
  context 'logged in as an admin user' do
    let!(:admin) { FactoryBot.create(:admin) }
    before { sign_in admin }

    describe 'GET #index' do
      it 'returns index page' do
        get :index
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
        expect(assigns(:school_terms).map { |school| school['label'] }).to eq [
          'Candler School of Theology',
          'Emory College',
          'Laney Graduate School',
          'Nell Hodgson Woodruff School of Nursing',
          'Rollins School of Public Health'
        ]
      end
    end

    describe 'GET #show' do
      let(:id) { 'Laney Graduate School' }

      it 'returns show page' do
        get :show, params: { id: id }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
        expect(assigns(:school).label).to eq 'Laney Graduate School'
      end
    end
  end

  context 'logged in as a student' do
    let!(:student) { FactoryBot.create(:user) }
    before { sign_in student }

    describe 'GET #index' do
      it 'denies access' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash.alert).to match(/You are not authorized/)
      end
    end

    describe 'GET #show' do
      let(:id) { 'Laney Graduate School' }

      it 'denies access' do
        get :show, params: { id: id }
        expect(response).to redirect_to(root_path)
        expect(flash.alert).to match(/You are not authorized/)
      end
    end
  end
end
