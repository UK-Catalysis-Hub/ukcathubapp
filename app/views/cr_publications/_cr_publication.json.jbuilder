json.extract! cr_publication, :id, :authors, :pub_year, :title, :doi, :awards, :xref_affi, :themes, :status, :note, :created_at, :updated_at
json.url cr_publication_url(cr_publication, format: :json)
