# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # 認証系（JWT不要）
      post 'auth/login', to: 'auth#login'
      post 'auth/signup', to: 'auth#signup'

      # 認証必須
      get 'auth/me', to: 'auth#me'

      # リソース系APIルート
      resources :customers, only: %i[index create show update destroy]
      # resources :work_records
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
