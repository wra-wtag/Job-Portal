Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }
  root "home#index"

  get 'profile', to: 'users#show'
  get 'profile/edit', to: 'users#edit'
  patch 'profile', to: 'users#update'
  get 'profile/setup', to: 'users#setup'
  
  resources :jobs, only: [:index, :show] do
    member do
      post :bookmark
      delete :unbookmark
      get :apply
      post :submit_application
    end
  end

  resources :applications, only: [:index, :show] do
    member do
      patch :withdraw
    end
  end

  resources :bookmarks, only: [:index, :destroy]

  namespace :recruiter do
    get "applications/index"
    get "applications/show"
    get "applications/update"
    get "jobs/index"
    get "jobs/show"
    get "jobs/new"
    get "jobs/create"
    get "jobs/edit"
    get "jobs/update"
    get "jobs/destroy"
    get "jobs/toggle_status"
    get "dashboard/index"
    get 'dashboard', to: 'dashboard#index'
    resources :companies, except: [:index] do
      resources :jobs do
        resources :applications, only: [:index, :show, :update]
      end
    end
  end

  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    resources :users
    resources :companies do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :jobs
  end

  get 'company/pending', to: 'companies#pending_approval', as: 'company_pending_approval'
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
