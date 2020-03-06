class HomeController < ApplicationController
  def index
    @articles = Article.latest
  end
end
