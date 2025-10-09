Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/signup", to: "authentication#signup"
      post "auth/login", to: "authentication#login"
      delete "auth/logout", to: "authentication#logout"
      get "auth/me", to: "authentication#me"

      resources :jobs, only: [ :index, :show ] do
        member do
          post :apply
        end
      end

      resources :companies, only: [ :index, :show ]

      resources :applications, only: [ :index, :show ]

      resource :profile, only: [ :show, :update ], controller: "profiles"
    end
  end
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    confirmations: "devise/confirmations"
  }
  root "home#index"

  get "profile", to: "users#show"
  get "profile/edit", to: "users#edit"
  patch "profile", to: "users#update"
  get "profile/setup", to: "users#setup"

  resources :jobs, only: [ :index, :show ] do
    member do
      post :bookmark
      delete :unbookmark
      get :apply
      post :submit_application
    end
  end

  resources :applications, only: [ :index, :show ] do
    member do
      patch :withdraw
    end
  end

  resources :bookmarks, only: [ :index, :destroy ]

  get "recruiter/pending", to: "recruiter_onboarding#pending", as: "recruiter_pending"
  get "recruiter/onboarding", to: "recruiter_onboarding#index", as: "recruiter_onboarding"
  get "recruiter/onboarding/join_company", to: "recruiter_onboarding#join_company", as: "join_company_recruiter_onboarding"
  post "recruiter/onboarding/submit_request", to: "recruiter_onboarding#submit_request"

  namespace :recruiter do
    get "dashboard", to: "dashboard#index"

    resources :jobs do
      member do
        patch :toggle_status
      end
    end

    resources :applications, only: [ :index, :show, :update ]
    resources :companies, only: [ :show, :edit, :update ]

    resources :team, only: [ :index ] do
      member do
        patch :approve_request
        patch :reject_request
        delete :remove_recruiter
      end
    end
  end

  namespace :admin do
    get "analytics/index"
    resources :recruiter_requests, only: [ :index, :show ] do
      member do
        patch :approve
        patch :reject
      end
    end

    get "dashboard", to: "dashboard#index"
    get "analytics", to: "analytics#index"

    resources :users
    resources :companies do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :jobs

    resources :recruiter_requests, only: [ :index, :show ] do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  resources :companies, only: [ :new, :create, :edit, :update ] do
    member do
      get :pending_approval
    end
  end
  get "company/pending", to: "companies#pending_approval", as: "company_pending_approval"

  resources :notifications, only: [ :index, :show, :destroy ] do
    collection do
      post :mark_all_as_read
    end
    member do
      post :mark_as_read
    end
  end
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq" if Rails.env.development?
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
