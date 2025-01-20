
class CrossrefPublication
  # verify article object agains CR record
  def self.verify_article(article)
    # get the article from crossref
    puts "** Verifying this: " + article.title
    digital_object_identifier = article.doi
    if digital_object_identifier != nil
      pub_data = XrefClient.getCRData(digital_object_identifier)
    else
      puts "no crossref data, doi is null"
    end
    # Thing that may change:
    #   Citation counts
    #   Details of authors (affiliation address, ORCID number) P
    #   container title update P
    if pub_data != nil
      citation_count_change(article, pub_data)
      change_in_authors(article, pub_data)
    end
  end

  def self.citation_count_change(article, pub_data)
    changes_found = false
    # only verify fields which may change between recoveries: citations
    if article.attributes['referenced_by_count'] != pub_data['is-referenced-by-count']
      changes_found = true
      article.attributes['referenced_by_count'] = pub_data['is-referenced-by-count']
      article.referenced_by_count = pub_data['is-referenced-by-count']
    end
    if changes_found
      article.save
    end
  end

  def self.change_in_authors(article, pub_data)
    if article.article_authors.count == 0 \
      or article.article_authors[0].last_name == nil
      puts "article does not have authors"
      self.get_authors(article, pub_data)
    end
  end
end  #Class CrossrefPublication 
