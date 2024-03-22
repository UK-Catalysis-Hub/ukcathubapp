class Dataset < ApplicationRecord
  #relationships to articles
  has_many :article_datasets
  has_many :articles, through: :article_datasets

  #scopes for datsets
  scope :latest, -> {order('startdate DESC').order('id DESC').limit(10)  }
  scope :repository_count, -> {select("repository, COUNT(*) AS 'r_count'").order("r_count DESC").group("repository")}
  scope :ds_per_year, -> {select("strftime('%Y', startdate) AS item, COUNT(*) AS 'i_count'").group("item")}
  scope :type_count, -> {select("ds_type, COUNT(*) AS 'i_count'").group("ds_type").order("ds_type")}
  scope :simple_type_count, -> {select(" CASE TRUE WHEN ds_type LIKE '%Document%' THEN 'Document [pdf/html/docx/ppt]' WHEN ds_type LIKE '%Video%' OR ds_type LIKE '%Image%' THEN 'Media File (image/video)' WHEN ds_type LIKE '%Software%' THEN 'Software [app/api/service/source code]' WHEN ds_type LIKE '%Nexus%' THEN 'Dataset'ELSE ds_type END do_type, count(), COUNT(*) AS 'i_count'").group("do_type").order("do_type")}
end
