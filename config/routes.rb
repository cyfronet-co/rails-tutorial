Rails.application.routes.draw do
  resources :grants
  root "welcome#index"
end
