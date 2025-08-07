Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    get "guest/homepage"
    get "signup", to: "users#new"
    post "signup", to: "users#create"

    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    get "/auth/:provider/callback", to: "sessions#omniauth"
    get "/auth/failure", to: redirect("/")
    namespace :user do
      resources :courses, only: %i(index show create) do
        resources :lessons, only: %i(show) do
          member do
            get :study
            get :test
            get :test_history
          end
        end
      end
    end
    root to: "guest#homepage"

    resources :users, only: %i(show)
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
