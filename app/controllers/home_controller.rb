class HomeController < ApplicationController
  def index
    @latest_articles = Article.latest
    @cited_articles = Article.most_cited
    @authors = Author.top_published
  end
end
