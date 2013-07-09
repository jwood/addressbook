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

  get 'settings/address' => 'settings#edit_address', :as => :settings_edit_address
  put 'settings/address' => 'settings#update_address', :as => :settings_update_address
  get 'settings/login_credentials' => 'settings#edit_login_credentials', :as => :settings_edit_login_credentials
  put 'settings/login_credentials' => 'settings#update_login_credentials', :as => :settings_update_login_credentials

  get 'use_desktop_view' => 'main#use_desktop_view'
  get 'use_mobile_view' => 'main#use_mobile_view'

  root :to => 'main#index'
end

