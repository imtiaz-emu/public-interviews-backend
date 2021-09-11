Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'login', to: 'authentication#create'
      post 'register', to: 'accounts#create'
    end
  end
end