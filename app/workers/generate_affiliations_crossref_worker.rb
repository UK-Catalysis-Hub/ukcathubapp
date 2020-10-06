# worker for going through all publication records and verify them against CR
class GenerateAffiliationsCrossrefWorker
  include Sidekiq::Worker
  # method that schedules the update of articles from crossref
  def perform
    puts '*************************************'
    puts 'Generate author affiliations from CR records'
    authors_list = Author.all
    puts '*************************************'
    puts "Authors to process " + authors_list.length.to_s
    CrossrefPublication.generate_author_affiliations(authors_list)
  end
end
