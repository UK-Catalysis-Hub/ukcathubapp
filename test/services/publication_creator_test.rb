require "test_helper"

class PublicationCreatorTest < ActiveSupport::TestCase
  setup do
    @article = articles(:one)
    @theme = themes(:one)
    @doi_existing = @article.doi
    @doi_uppercase = @doi_existing.upcase
    @doi_spaces = " " + @doi_existing + " "
    @doi_spc_n_uc =  " " + @doi_existing + " "
    @theme_list = [@theme.id]
  end
  
  test "should not add an existing publication" do
    assert_no_difference("Article.count()") do
      result = PublicationCreator.call({'doi': @doi_existing, 'themes': @theme_list})
    end
  end
  
  test "should ingnore doi case when adding" do
    assert_no_difference("Article.count()") do
      result = PublicationCreator.call({'doi': @doi_uppercase, 'themes': @theme_list})
    end  
  end
  
  test "should trim doi when adding" do
    assert_no_difference("Article.count()") do
      result = PublicationCreator.call({'doi': @doi_spaces , 'themes': @theme_list})
    end  
  end
  
  test "should trim and downcase doi when adding" do
    assert_no_difference("Article.count()") do
      result = PublicationCreator.call({'doi': @doi_spc_n_uc, 'themes': @theme_list})
    end  
  end
end
