json.extract! article_author, :id, :doi, :author_id, :author_count, :author_order, :status, :author_seq, :article_id, :orcid, :last_name, :given_name, :created_at, :updated_at
json.url article_author_url(article_author, format: :json)
