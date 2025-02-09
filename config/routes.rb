Rails.application.routes.draw do
  root to: "users#new"

  resources :users, only: [:new, :create, :show] do
    member do
      get :verify
      post :confirm_verification
      post :resend_verification_code
    end
  end
  resources :sessions, only: [:new, :create]
  delete "logout", to: "sessions#destroy"
end
