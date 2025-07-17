require "test_helper"

class PublicationCreatorTest < ActiveSupport::TestCase
  setup do
    @article = articles(:one)
    @theme = themes(:one)
    @doi_existing = @article.doi
    @doi_uppercase = @doi_existing.upcase
    @doi_spaces = " " + @doi_existing + " "
    @doi_spc_n_uc =  " " + @doi_existing + " "
    # the firs doi has a xiv string in doi,
    # the second does not have pub_year
    @preprint_dois = ["10.26434/chemrxiv-2024-cpjsk",
                      "10.1101/2025.07.05.663138"]
    @ok_doi = "10.1021/acsmaterialslett.1c00766"

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
  
  test "should not add preprints" do
    @preprint_dois.each do |pp_doi|
      assert_no_difference("Article.count()") do
        result = PublicationCreator.call({'doi': pp_doi, 'themes': @theme_list})
      end
    end
  end
  
  test "should add OK" do
    auth_count = Author.count
    art_auth_count = ArticleAuthor.count
    art_theme_count = ArticleTheme.count
    cr_affi_count = CrAffiliation.count
    assert_difference("Article.count()") do
      result = PublicationCreator.call({'doi': @ok_doi, 'themes': @theme_list})
    end
    assert_equal(auth_count+2, Author.count)

    assert_equal(art_auth_count+2, ArticleAuthor.count)

    assert_equal(art_theme_count+1, ArticleTheme.count)

    assert_equal(cr_affi_count+4, CrAffiliation.count)
  end
end
