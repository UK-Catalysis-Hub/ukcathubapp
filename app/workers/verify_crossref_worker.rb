# worker for going through all publication records and verify them against CR
class VerifyCrossrefWorker
  include Sidekiq::Worker
  def perform
    puts 'verify all publications against CR records'
    date_from = Date.today - 30
    articles_list = Article.where("updated_at < ?", date_from)
    #break counter
    bk_i = 1
    articles_list.each do |an_article|
      doi_text = an_article.doi
      verify_articles(an_article)
      if bk_i == 10
        break
      end
      bk_i += 1
    end
  end
  
  def getCRData(doi_text)
    begin
        #puts "trying"
        art_bib = JSON.parse(Serrano.content_negotiation(ids: doi_text, format: "citeproc-json"))
        return art_bib
    rescue
        #puts "failing"
        return nil
    end
  end

  def verify_articles(article)
    # get the article from crossref
    doi_text = article.doi
    art_id = article.id
    pub_data = getCRData(doi_text)
    changes_found = false
    # only verify fields which may chenge between recoveries, eg: citations
    if article.attributes['referenced_by_count'] != pub_data['is-referenced-by-count']
      changes_found = true
      article.attributes['referenced_by_count'] = pub_data['is-referenced-by-count']
      article.referenced_by_count = pub_data['is-referenced-by-count']
    end
    if changes_found
      article.save
    end
    aut_order = 1
    pub_data['author'].each do |art_author|
      changes_found = false
      new_author = ArticleAuthor.new()
      if art_id != nil
        tem_auth = ArticleAuthor.find_by article_id: art_id, author_order: aut_order
        if tem_auth != nil
          new_author = tem_auth
        end
      end
      if art_author.keys.include?('ORCID')
        if  new_author.orcid != art_author['ORCID']
          changes_found = true
          new_author.orcid = art_author['ORCID']
        end
      end
      if art_author.keys.include?('family')
        if new_author.last_name != art_author['family']
          changes_found = true
          new_author.last_name = art_author['family']
        end
      end
      if art_author.keys.include?('given')
        if new_author.given_name != art_author['given']
          changes_found = true
          new_author.given_name = art_author['given']
        end
      end
      if changes_found
        new_author.save
      end
      aut_id = new_author.id
      if art_author.keys.include?('affiliation')
        if art_author['affiliation'].length > 0
          art_author['affiliation'].each do |temp_affi|
            new_affi = CrAffiliation.new()
            affi_text = temp_affi['name']
            if aut_id != nil
              tem_affi = CrAffiliation.find_by article_author_id: aut_id, name: affi_text
              if tem_affi != nil
                new_affi = tem_affi
              else
                new_affi.name = temp_affi['name']
                new_affi.article_author_id = aut_id
                new_affi.save
              end
            end
          end
        end
      end
      aut_order += 1
    end
  end

end
