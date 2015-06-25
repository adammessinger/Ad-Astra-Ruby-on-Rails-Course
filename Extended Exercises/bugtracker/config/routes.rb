Rails.application.routes.draw do
  devise_for :users
  resources :bugs

  root(to: 'bugs#index')
end
