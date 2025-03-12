class HomeController < ApplicationController
  def index
    @latest_articles = Article.latest
    @cited_articles = Article.most_cited
    @home_data = Section.where("obj_name='Home'")[0] 
    @theme_data = Section.where("obj_name='Themes'")[0]
    @do_data = Section.where("obj_name='Datasets'")[0]
  end
end
