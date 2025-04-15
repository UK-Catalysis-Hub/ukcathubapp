class SearchCrossrefWorkerJob

  include Sidekiq::Job
  # method that schedules the update of articles from crossref
  def perform
    CrossrefPublication.search_crosreff
    puts "started search for publications"
  end
end
