Rails.application.routes.draw do
  resources :grants do
    resources :allocations, only: [:new, :create]
  end
  root "welcome#index"
end
