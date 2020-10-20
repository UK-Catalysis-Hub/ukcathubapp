class HomeController < ApplicationController
  def index
    @latest_articles = Article.latest
    @cited_articles = Article.most_cited
  end
end
