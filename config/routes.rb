Rails.application.routes.draw do
  mount Blacklight::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }
  # These routes are provided by Devise's database_authenticatable. If we remove
  # database_authenticatable (as we will need to, eventually) we need to put these back
  # so omniauth and shibboleth have them.
  # devise_scope :user do
  #   get 'sign_in', to: 'devise/sessions#new', as: :new_user_session
  #   post 'sign_in', to: 'devise/session#create', as: :session
  #   get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  # end

  mount BrowseEverything::Engine => '/browse'
  mount ResqueWeb::Engine => '/resque'
  mount Hydra::RoleManagement::Engine => '/'
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
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
end
