# Database authentication

In production, we want to use shibboleth exclusively for user authentication.
However, authenticating to Shibboleth from your local development environment
isn't feasible. Instead, you'll want to set up local database authentication.

1. Edit `app/models/user.rb` and add `:database_authenticatable` to devise, around line 20
2. Comment these lines out of `config/routes.rb`:
```
devise_scope :user do
    get 'sign_in', to: 'omniauth#new', as: :new_user_session
    post 'sign_in', to: 'omniauth_callbacks#shibboleth', as: :new_session
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
end
```
3. Edit `lib/workflow_setup.rb` and make passwords for all your admin users. You
will want to re-run `rake db:seed` to re-generate those user accounts.
4. Edit `app/views/devise/sessions/new.html.erb` to add back in the log in form:
```
<%= simple_form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
  <div class="form-inputs">
    <%= f.input :uid, required: true, autofocus: true %>
    <%= f.input :password, required: true %>
    <%= f.input :remember_me, as: :boolean if devise_mapping.rememberable? %>
  </div>

  <div class="form-actions">
    <%= f.button :submit, "Log in" %>
  </div>
<% end %>
```
