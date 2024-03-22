json.extract! article, :id, :doi, :title, :pub_year, :pub_type, :publisher, :container_title, :volume, :issue, :page, :pub_print_year, :pub_print_month, :pub_print_day, :pub_ol_year, :pub_ol_month, :pub_ol_day, :license, :referenced_by_count, :link, :url, :abstract, :status, :comment, :references_count, :journal_issue, :created_at, :updated_at
json.url article_url(article, format: :json)
