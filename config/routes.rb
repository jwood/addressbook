Addressbook::Application.routes.draw do
  resource :address

  resource :contact do
    member do
      post :change_address_for_contact
      post :remove_address_from_contact
      get  :find
    end
  end

  resource :group do
    member do
      get  :create_labels
    end
  end

  match 'settings/address' => 'settings#edit_address', :as => :settings_edit_address, :via => :get
  match 'settings/address' => 'settings#update_address', :as => :settings_update_address, :via => :post
  match 'settings/login_credentials' => 'settings#edit_login_credentials', :as => :settings_edit_login_credentials, :via => :get
  match 'settings/login_credentials' => 'settings#update_login_credentials', :as => :settings_update_login_credentials, :via => :post

  root :to => 'main#index'
  match '/:controller(/:action(/:id))'
end

