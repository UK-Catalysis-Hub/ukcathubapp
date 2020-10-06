Rails.application.routes.draw do
  resources :author_affiliations
  resources :cr_affiliations
  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}
  resources :article_datasets
  resources :datasets
  get 'home/index'
  resources :articles
  #get "issues/cancel_return" => "issues#cancel_return"
  resources :article_themes
  resources :article_authors
  post 'link_to_researcher' => 'article_authors#link_to_researcher', as: :link_to_researcher
  resources :affiliation_links
  resources :affiliations
  resources :addresses
  resources :authors
  # custom route to verify methods
  post 'verify' => 'articles#verify', as: :verify
  post 'generate_affiliations' => 'authors#generate', as: :generate_auth_affis
  resources :themes
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
end
