Rails.application.routes.draw do
  get 'home/index'
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
