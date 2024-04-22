Rails.application.routes.draw do
  namespace :admin do
    resources :orders
    resources :products do
      resources :stocks
    end
    resources :categories
  end
  devise_for :admins
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"

  # this is rails helpers that connects with devise using is_signed_in? and current_user i think lol
  # it says: if admin_user is authenticated send it to admin#index the root of the admin page
  #
  authenticated :admin_user do
    root to: "admin#index", as: :admin_root
  end

  resources :categories, only:  [:show]
  resources :products, only: [:show]
  # resources :orders, only: [:show]

  get "admin" => "admin#index"
  get "category" => "category#index"
  get "cart" => "cart#show"
  post "checkout" => "checkout#create"
  get "success" => "checkout#success"
  get "cancel" => "checkout#cancel"
  post "webhooks" => "webhooks#stripe"

end
