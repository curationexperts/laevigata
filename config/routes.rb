require 'sidekiq/web'

Rails.application.routes.draw do
  mount Blacklight::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  # Disable these routes if you are using Devise's
  # database_authenticatable in your development environment.
  unless AuthConfig.use_database_auth?
    devise_scope :user do
      get 'sign_in', to: 'omniauth#new', as: :new_user_session
      post 'sign_in', to: 'omniauth_callbacks#shibboleth', as: :new_session
      get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
    end
  end

  mount BrowseEverything::Engine => '/browse'
  mount Hydra::RoleManagement::Engine => '/'
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'

  resources :in_progress_etds, except: [:create, :show, :index]
  get '/concern/etds/new', to: redirect('in_progress_etds/new')
  # Just in case we missed any edit links anywhere in the app, this redirect should make sure we always have the form from the new UI when we try to edit an ETD.
  get '/concern/etds/:id/edit', to: redirect('in_progress_etds/new?etd_id=%{id}')

  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  delete '/uploads/:id', to: 'hyrax/uploads#destroy', as: :uploaded_file
  post '/uploads', to: 'hyrax/uploads#create'
  # This is a hack that is required because the rails form the uploader is on
  # sets the _method parameter to patch when the work already exists.
  # Eventually it would be good to update the javascript so that it doesn't
  # submit the form, just the file and always uses POST.
  patch '/uploads', to: 'hyrax/uploads#create'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Mount sidekiq web ui and require authentication by an admin user

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :schools, only: [:index, :show]

  get '/auth/box', to: 'box_auth#auth'
  post '/file/box', to: 'box_redirect#redirect_file'

  get 'error_404', to: 'pages#error_404'
  # If you go somewhere without a route, show a 404 page
  match '*path', via: :all, to: 'pages#error_404'
end
