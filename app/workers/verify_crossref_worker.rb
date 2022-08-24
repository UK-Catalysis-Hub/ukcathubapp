# worker for going through all publication records and verify them against CR
class VerifyCrossrefWorker
  include Sidekiq::Worker

  # method that schedules the update of articles from crossref
  def perform
    puts 'verify all publications against CR records'
    date_from = Date.today
    articles_list = Article.where("updated_at < ?", date_from)
    puts "Articles to verify " + articles_list.length.to_s
    articles_list.each do |an_article|
      CrossrefPublication.verify_article(an_article)
    end
  end

end
