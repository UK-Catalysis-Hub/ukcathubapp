Rails.application.routes.draw do

  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  #get 'sessions/new'
  resources :users
  resources :sessions
  resources :article_datasets
  resources :datasets
  #get 'home/index'
  resources :articles
  resources :article_themes
  resources :article_authors
  resources :affiliation_links
  resources :affiliations
  resources :addresses
  resources :authors
  resources :themes
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
end
