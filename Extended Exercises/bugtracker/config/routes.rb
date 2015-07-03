Rails.application.routes.draw do
  devise_for :users
  resources :bugs do
    resources :comments
  end

  root(to: 'bugs#index')
end
