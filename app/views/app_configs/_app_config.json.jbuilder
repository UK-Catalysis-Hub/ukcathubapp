json.extract! app_config, :id, :title, :broser_tab_name, :favicon, :logo, :organisation_id, :contact_id, :contact_email, :award_list, :synon_list, :created_at, :updated_at
json.url app_config_url(app_config, format: :json)
