Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :transactions, only: %i[index create show]
      post 'login', to: 'authentication#create'
      post 'register', to: 'accounts#create'
    end
  end
end