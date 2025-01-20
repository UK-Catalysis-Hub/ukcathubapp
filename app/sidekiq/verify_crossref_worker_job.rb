class VerifyCrossrefWorkerJob
  include Sidekiq::Job

#  def perform(*args)
#    # Do something
#  end
  
    # method that schedules the update of articles from crossref
  def perform
    puts 'verify all publications against CR records'
    date_from = Date.today + 1
    articles_list = Article.where("updated_at < ?", date_from)
    puts "Articles to verify " + articles_list.length.to_s
    articles_list.each do |an_article|
      puts an_article.doi
      #pub_data = CrossrefApiClient.getCRData(an_article.doi)
      CrossrefPublication.verify_article(an_article)
    end
  end
end
