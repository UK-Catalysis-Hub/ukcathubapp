json.extract! cr_publication, :id, :authors, :pub_year, :title, :doi, :awards, :affiliation, :themes, :status, :created_at, :updated_at
json.url cr_publication_url(cr_publication, format: :json)
