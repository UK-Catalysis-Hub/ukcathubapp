json.extract! article, :id, :reference_count, :publisher, :issue, :license, :pub_print_year, :pub_print_month, :pub_print_day, :doi, :pub_type, :page, :title, :volume, :pub_ol_year, :pub_ol_month, :pub_ol_day, :container_title, :link, :references_count, :journal_issue, :url, :abstract, :status, :comment, :created_at, :updated_at
json.url article_url(article, format: :json)
