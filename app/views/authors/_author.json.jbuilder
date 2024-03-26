json.extract! author, :id, :last_name, :given_name, :orcid, :articles, :created_at, :updated_at
json.url author_url(author, format: :json)
