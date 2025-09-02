Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # Defines the root path route ("/")
  # root "posts#index"

  # Devise Authentication Routes
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }  

  namespace :api do
    namespace :v1 do
      # Events Routes (Only Event Organizers can manage events)
      resources :events do
        resources :tickets, only: [:index, :create] 
      end

      # Bookings Routes (Only Customers can book tickets)
      resources :bookings, only: [:index, :create]
      # post '/icecast/authenticate', to: 'icecast#authenticate'
      # post '/icecast/start_stream', to: 'icecast#start_stream'
      resources :broadcasts, only: [:create] do
        collection do
          post :start
          post :stop
        end
      end
    end
  end
end
