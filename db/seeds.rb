# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([XrefClient::Mapping.create( name: 'Star Wars' ), XrefClient::Mapping.create( name: 'Lord of the Rings' )])
#   Character.create(name: 'Luke', movie: movies.first)

# Mappings for Article
XrefClient::Mapping.create(obj_name: "Article", origin: nil, target:  "id", target_type:  "integer", default:  "NOT NULL", json_paths:  nil, evaluate:  nil, other:  "autoDB")
XrefClient::Mapping.create(obj_name: "Article", origin: "DOI", target:  "doi", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "title", target:  "title", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "type", target:  "pub_type", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "publisher", target:  "publisher", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "container-title", target:  "container_title", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "volume", target:  "volume", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "issue", target:  "issue", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "page", target:  "page", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "published-print", target:  "pub_print_year", target_type:  "integer", default:  "NULL", json_paths:  "[['published-print','date-parts',0,0],['journal_issue','published-print','date-parts',0,0]]", evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "published-print", target:  "pub_print_month", target_type:  "integer", default:  "NULL", json_paths:  "[['published-print','date-parts',0,1],['journal_issue','published-print','date-parts',0,1]]", evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "published-print", target:  "pub_print_day", target_type:  "integer", default:  "NULL", json_paths:  "[['published-print','date-parts',0,2],['journal_issue','published-print','date-parts',0,2]]", evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "published-online", target:  "pub_ol_year", target_type:  "integer", default:  "NULL", json_paths:  "[['published-online','date-parts',0,0],['journal_issue','published-online','date-parts',0,0]]", evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "published-online", target:  "pub_ol_month", target_type:  "integer", default:  "NULL", json_paths:  "[['published-online','date-parts',0,1],['journal_issue','published-online','date-parts',0,1]]", evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "published-online", target:  "pub_ol_day", target_type:  "integer", default:  "NULL", json_paths:  "[['published-online','date-parts',0,2],['journal_issue','published-online','date-parts',0,2]]", evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: nil, target:  "pub_year", target_type:  "integer", default:  "NULL", json_paths:  nil, evaluate:  "d_h['pub_print_year'] == nil ? (d_h['pub_ol_year']  == nil ? nil : d_h['pub_ol_year'] ) : (d_h['pub_ol_year'] ==nil ? d_h['pub_print_year']  : d_h['pub_print_year']   < d_h['pub_ol_year']  ? d_h['pub_print_year']  : d_h['pub_ol_year'] )", other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "license", target:  "license", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "is-referenced-by-count", target:  "referenced_by_count", target_type:  "integer", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "link", target:  "link", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "url", target:  "url", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "abstract", target:  "abstract", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: nil, target:  "status", target_type:  "varchar", default:  "'New’", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: nil, target:  "comment", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: nil, target:  "created_at", target_type:  "datetime", default:  "NOT NULL", json_paths:  nil, evaluate:  nil, other:  "autoDB")
XrefClient::Mapping.create(obj_name: "Article", origin: nil, target:  "updated_at", target_type:  "datetime", default:  "NOT NULL", json_paths:  nil, evaluate:  nil, other:  "autoDB")
XrefClient::Mapping.create(obj_name: "Article", origin: "references-count", target:  "references_count", target_type:  "integer", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "Article", origin: "journal-issue", target:  "journal_issue", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)

# Mappings for Article Author
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: nil, target:  "id", target_type:  "integer", default:  "NOT NULL", json_paths:  nil, evaluate:  nil, other:  "autoDB")
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: "DOI", target:  "doi", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  "article doi")
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: nil, target:  "author_id", target_type:  "integer", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  "Match to existing or create new")
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: nil, target:  "author_count", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  "Ignore do not use any more")
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: nil, target:  "author_order", target_type:  "integer", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  "sequential in order of appearance")
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: nil, target:  "status", target_type:  "varchar", default:  "not verified", json_paths:  nil, evaluate:  nil, other:  "manual, verified if match found")
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: "sequence", target:  "author_seq", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: nil, target:  "article_id", target_type:  "integer", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  "Link to article record")
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: "ORCID", target:  "orcid", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: "family", target:  "last_name", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: "given", target:  "given_name", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: nil, target:  "updated_at", target_type:  "datetime", default:  "NOT NULL", json_paths:  nil, evaluate:  nil, other:  "autoDB")
XrefClient::Mapping.create(obj_name: "ArticleAuthor", origin: nil, target:  "created_at", target_type:  "datetime ", default:  "NOT NULL", json_paths:  nil, evaluate:  nil, other:  "autoDB")

# Mappings for Crossref affiliation
XrefClient::Mapping.create(obj_name: "CrAffiliation", origin: nil, target:  "id", target_type:  "integer", default:  "NOT NULL", json_paths:  nil, evaluate:  nil, other:  "autoDB")
XrefClient::Mapping.create(obj_name: "CrAffiliation", origin: "name", target:  "name", target_type:  "varchar", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  nil)
XrefClient::Mapping.create(obj_name: "CrAffiliation", origin: nil, target:  "article_author_id", target_type:  "integer", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  "article_author.id")
XrefClient::Mapping.create(obj_name: "CrAffiliation", origin: nil, target:  "author_affiliation_id", target_type:  "integer", default:  "NULL", json_paths:  nil, evaluate:  nil, other:  "author_affiliation.id")
XrefClient::Mapping.create(obj_name: "CrAffiliation", origin: nil, target:  "created_at", target_type:  "datetime(6)", default:  "NOT NULL", json_paths:  nil, evaluate:  nil, other:  "autoDB")
XrefClient::Mapping.create(obj_name: "CrAffiliation", origin: nil, target:  "updated_at", target_type:  "datetime(6)", default:  "NOT NULL", json_paths:  nil, evaluate:  nil, other:  "autoDB")


