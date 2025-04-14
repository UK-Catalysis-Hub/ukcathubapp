Rails.application.routes.draw do
  resources :cr_publications
  resources :app_configs, only: [:edit, :update, :create]
  resources :organisations
  resources :sections
  devise_for :users
  
  resources :themes
  resources :datasets
  resources :cr_affiliations
  resources :authors
  resources :author_affiliations
  resources :articles
  resources :article_themes
  resources :article_datasets
  resources :article_authors
  resources :affiliations
  resources :addresses

  get 'home/index'
  root 'home#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # download article stats csv
  get 'get_art_stats' => 'articles#arts_by_year_stats', as: 'get_art_stats'

  get 'ctry_stats' => 'affiliations#ctry_affi_count', as: 'ctry_stats'
  get 'themes_count' => 'themes#themes_count', as: 'themes_count'

  post 'link_to_theme' => 'article_themes#link_to_theme', as: :link_to_theme

  post 'verify' => 'articles#verify', as: :verify
  post 'upload_csv' => 'articles#upload_csv', as: :upload_csv

  get 'data_count' => 'datasets#data_count', as: 'data_count'
  post 'upload_data' => 'datasets#upload_data', as: 'upload_data'

  post 'link_to_researcher' => 'article_authors#link_to_researcher', as: :link_to_researcher

  post 'generate_affiliations' => 'authors#generate', as: :generate_auth_affis

  # get publications bibliography service
  get 'get_pubs' => 'articles#bib_query', as: :getpubs

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount XrefClient::Engine, at: "/xref_client"
end
