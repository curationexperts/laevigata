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
  # While we work on different UI architecture, keep it in a separate controller, accessible only when the new_ui flip is
  # true (see config/new_ui.yml).

  # Before db creation during setup of project, we can't check FlipFlop because its tables do not yet exist,
  # and rake tasks require loading the application, including this file - so rake db:create will fail here. Skip the FlipFlop check # unless the tables it relies on are present.

  if ActiveRecord::Base.connection.data_source_exists? 'hyrax_features'
    if Flipflop.new_ui?
      get '/concern/etds/new', to: 'hyrax/new_ui#new'
    else
      get '/concern/etds/new', to: 'hyrax/etds#new'
    end
  end
  curation_concerns_basic_routes
  # TODO: remove the following line, it has been deprecated and no longer has any effect --

  curation_concerns_embargo_management
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

  match "*path", to: "catalog#catch_404", via: :all
end
