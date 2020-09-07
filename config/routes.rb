Rails.application.routes.draw do
  resources :cr_afiliations
  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}
  resources :article_datasets
  resources :datasets
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
