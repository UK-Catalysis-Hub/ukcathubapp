json.extract! article_dataset, :id, :doi, :article_id, :dataset_id, :created_at, :updated_at
json.url article_dataset_url(article_dataset, format: :json)
