Addressbook::Application.routes.draw do
  resources :addresses

  resources :contacts do
    member do
      post :change_address
      post :remove_address
    end
    get :find, :on => :collection
  end

  resources :groups do
    get  :create_labels, :on => :member
  end

  match 'settings/address' => 'settings#edit_address', :as => :settings_edit_address, :via => :get
  match 'settings/address' => 'settings#update_address', :as => :settings_update_address, :via => :put
  match 'settings/login_credentials' => 'settings#edit_login_credentials', :as => :settings_edit_login_credentials, :via => :get
  match 'settings/login_credentials' => 'settings#update_login_credentials', :as => :settings_update_login_credentials, :via => :put

  match 'use_desktop_view' => 'main#use_desktop_view'
  match 'use_mobile_view' => 'main#use_mobile_view'

  root :to => 'main#index'
end

