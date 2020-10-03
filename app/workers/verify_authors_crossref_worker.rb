# worker for going through all publication records and verify them against CR
class VerifyAuthorsCrossrefWorker
  include Sidekiq::Worker
  # method that schedules the update of articles from crossref
  def perform
    puts '*************************************'
    puts 'verify author affiliations against CR records'
    authors_list = Author.all
    puts '*************************************'
    puts "Authors to verify " + authors_list.length.to_s
    CrossrefPublication.verify_author_affiliations(authors_list)
  end
end
