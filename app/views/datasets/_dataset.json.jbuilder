json.extract! dataset, :id, :dataset_complete, :dataset_description, :dataset_doi, :dataset_enddate, :dataset_location, :dataset_name, :dataset_startdate, :created_at, :updated_at
json.url dataset_url(dataset, format: :json)
