class VerifyCrossrefWorkerJob

  include Sidekiq::Job
  # method that schedules the update of articles from crossref
  def perform
    tmp_counter = 0
    #puts "Rails.logger=#{Rails.logger.object.id}"
    #puts "Sidekiq.logger=#{Sidekiq.logger.object.id}"

    Rails.logger.info 'verify all publications against CR records'
    date_from = Date.today + 1
    articles_list = Article.where("updated_at < ?", date_from)
    Rails.logger.debug "Articles to verify: " + articles_list.length.to_s
    tmp_counter = 0
    articles_list.each do |an_article|
      tmp_counter += 1
      puts an_article.doi
      #pub_data = CrossrefApiClient.getCRData(an_article.doi)
      last_checked = an_article.updated_at.day - DateTime.now.day +
                     an_article.updated_at.month - DateTime.now.month +
                     an_article.updated_at.year - DateTime.now.year 
      if last_checked == 0
        Rails.logger.info "not checking this" + an_article.id.to_s
        #tmp_counter = 0
      else
        CrossrefPublication.verify_article(an_article)
        an_article.updated_at = DateTime.now
        an_article.save!() # changes update date to register the last time it was checked
        Rails.logger.info  "Saved article " + an_article.id.to_s
      end
      if tmp_counter == 100
        break
      end
    end
  end
end
