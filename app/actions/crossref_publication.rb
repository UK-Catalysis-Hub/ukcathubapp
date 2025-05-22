
class CrossrefPublication
  # verify article object agains CR record
  def self.verify_article(article)
    # get the article from crossref
    puts "** 1 Verifying this: " + article.title
    digital_object_identifier = article.doi
    if digital_object_identifier != nil
      pub_data = XrefClient.getCRData(digital_object_identifier)
    else
      puts "2 No crossref data, doi is null"
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
      puts "3 article does not have authors"
      # puts pub_data
      #self.get_authors(article, pub_data) # this is not working need the get)authors method
    end
  end

  def self.search_crossref()
    # this list should come from configuration
    ukch_awards = ["EP/R026939/1", "EP/R026815/1", "EP/R026645/1", "EP/R027129/1",
                   "EP/M013219/1","EP/R026939", "EP/R026815", "EP/R026645",
                   "EP/R027129", "EP/M013219","EP/K014706/2", "EP/K014668/1",
                   "EP/K014854/1", "EP/K014714/1","EP/K014706", "EP/K014668",
                   "EP/K014854", "EP/K014714"]
    # calculate from_date and to_date, one month from last update until today
    awards_list = AppConfig.first!.award_list
    if awards_list.nil? or awards_list.length == 0
      awards_list = ukch_awards
    else
      awards_list = awards_list.split(',').map(&:strip)
    end
    from_date = (Article.latest()[0].created_at - 30.days).strftime("%Y-%m-%d")

    to_date = DateTime.now().to_s().strftime("%Y-%m-%d")
    # if award list is empty then look for affiliations?
    found_articles = XrefClient.findPubsAward(awards_list, from_date, to_date)
    #puts "*"*60
    #puts "Articles from crossref #{found_articles.count()}"
    #puts "*"*60
    found_articles.each do |a_doi, an_article|
      an_article[:status] = 0 # pending
      # ignore if doi is in cr_publications
      next if CrPublication.where("doi= '#{a_doi}'").exists?()
      # if doi arxiv then add, set status = 2 (rejected), comment it is a preprint
      if a_doi.include?('rxiv') 
        an_article[:status] = 2 # reject
        an_article[:note] = "It's a preprint"
      end
      # if doi in DB already add, set status = 2 (rejected), comment alredy in DB
      if Article.where("doi= '#{an_article[:doi]}'").exists?()
        an_article[:status] = 2 # reject
        an_article[:note] = "Already in DB"
      end  
      # add to cr_pubs
      new_pub = CrPublication.new(an_article)
      new_pub.save()
    end
  end

  # need to add all methods for parsing crossref data here
  # |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  # V  V  V  V  V  V  V  V  V  V  V  V  V  V  V  V
end  #Class CrossrefPublication 
