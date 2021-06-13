Rails.application.routes.draw do
  resources :grants do
    resources :allocations, only: [:new, :create]
  end
  root "welcome#index"

  delete 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
end
