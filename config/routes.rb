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
  post 'link_to_theme' => 'article_themes#link_to_theme', as: :link_to_theme
  resources :article_authors
  post 'link_to_researcher' => 'article_authors#link_to_researcher', as: :link_to_researcher
  resources :affiliations
  resources :addresses
  resources :authors
  # custom route to verify methods
  post 'verify' => 'articles#verify', as: :verify
  post 'upload_csv' => 'articles#upload_csv', as: :upload_csv
  post 'generate_affiliations' => 'authors#generate', as: :generate_auth_affis
  resources :themes
  get 'themes_count' => 'themes#themes_count', as: 'themes_count'
  get 'data_count' => 'datasets#data_count', as: 'data_count'
  post 'upload_data' => 'datasets#upload_data', as: 'upload_data'
  get 'ctry_stats' => 'affiliations#ctry_affi_count', as: 'ctry_stats'
  get 'get_pubs' => 'articles#bib_query', as: :getpubs
  # download article stats csv
  get 'get_art_stats' => 'articles#arts_by_year_stats', as: 'get_art_stats'
  root 'home#index'
end
