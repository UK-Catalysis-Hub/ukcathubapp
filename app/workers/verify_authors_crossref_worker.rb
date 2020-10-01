# worker for going through all publication records and verify them against CR
class VerifyAuthorsCrossrefWorker
  include Sidekiq::Worker
  # method that schedules the update of articles from crossref
  def perform
    puts '*************************************'
    puts 'verify authors for against CR records'
    date_from = Date.today - 30
    authors_list = Author.where("updated_at < ?", date_from)
    puts '*************************************'
    puts "Authors to verify " + authors_list.length.to_s
    CrossrefPublication.verify_author_affiliations(authors_list)
  end
end
