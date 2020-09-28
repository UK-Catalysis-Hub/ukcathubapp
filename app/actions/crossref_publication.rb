# app/actions/crossref_publication.rb

# custom class for mapping crossref data to the database (rails models)
# publication is the base class which contains:
#   - publication details (journal, editon, publication date, etc)
#   - author details (name, orcid, affilition, etc.)
#   - affilition details (name, address, country, etc.)
class CrossrefPublication

  # verify article object agains CR record
  def self.verify_article(article)
    # get the article from crossref
    puts "** Verifying this: " + article.title 
    digital_object_identifier = article.doi
    pub_data = CrossrefApiClient.getCRData(digital_object_identifier)
    if pub_data != nil
      art_id = article.id
      changes_found = false
      # only verify fields which may chenge between recoveries: citations
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
end
