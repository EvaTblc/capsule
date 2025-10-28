Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Debug route
  get "debug/auth" => "application#debug_auth" if Rails.env.development?

  # Defines the root path route ("/")
  root "pages#home"
  resources :collections do
    resources :categories do
      resources :items do
        collection do
          get :scan
          post :intake
          get :search_game
        end
        resources :items_tags
      end
    end
  end

  # resources :categories, only: [:destroy]
end
