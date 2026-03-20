Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :schools,    only: [:index, :show]
      resources :classrooms, only: [:index, :show]
      resources :students,   only: [:index, :show]
      resources :guardians,  only: [:index, :show]

      resources :announcements do
        member do
          post :send,  action: :send_announcement
          get  :stats, action: :stats
        end
      end

      resources :delivery_logs, only: [] do
        member do
          post :read
        end
      end

    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
