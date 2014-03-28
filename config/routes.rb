Omniauth::Application.routes.draw do
  root :to => "secrets#index"
  
  get '/sign_in' => "sessions#new"
  get "/auth/:provider/callback" => "sessions#create"
  get "/signout" => "sessions#destroy", :as => :signout
end
