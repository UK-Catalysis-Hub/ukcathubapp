class SearchCrossrefWorkerJob

  include Sidekiq::Job
  # method that schedules the update of articles from crossref
  def perform
    CrossrefPublication.search_crossref
    logger.info "started search for publications"
  end
end
