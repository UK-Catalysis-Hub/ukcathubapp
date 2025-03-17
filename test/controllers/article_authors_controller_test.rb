require "test_helper"

class ArticleAuthorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article_author = article_authors(:one)
    
    # Fix to problem rollback with no errors: rails doesn't allow modifying an
    # instance that has through associations. There are no exceptions messages,
    # just rollbacks.
    # To debug needs to run console and try so save using BANG, this is:
    #   > a.save!
    #    TRANSACTION (0.1ms)  begin transaction
    #    TRANSACTION (0.1ms)  rollback transaction
    #    /home.../active_record/validations.rb:84:in `raise_validation_error': 
    #    Validation failed: Author must exist, Article must exist 
    #    (ActiveRecord::RecordInvalid)
    # info from: https://stackoverflow.com/questions/9060014/
    sign_in users(:one)
    @article_author.author_id = authors(:one).id
    @article_author.article_id = articles(:one).id    
   
  end

  test "should get index" do
    get article_authors_url
    assert_response :success
  end

  test "should get new" do
    get new_article_author_url
    assert_response :success
  end

  test "should create article_author" do
  
    assert_difference("ArticleAuthor.count") do
      post article_authors_url, params: { article_author: { article_id: @article_author.article_id, author_count: @article_author.author_count, author_id: @article_author.author_id, author_order: @article_author.author_order, author_seq: @article_author.author_seq, doi: @article_author.doi, given_name: @article_author.given_name, last_name: @article_author.last_name, orcid: @article_author.orcid, status: @article_author.status } }
    end

    assert_redirected_to article_author_url(ArticleAuthor.last)
  end

  test "should show article_author" do
    get article_author_url(@article_author)
    assert_response :success
  end

  test "should get edit" do
    get edit_article_author_url(@article_author)
    assert_response :success
  end

  test "should update article_author" do
    patch article_author_url(@article_author), params: { article_author: { article_id: @article_author.article_id, author_count: @article_author.author_count, author_id: @article_author.author_id, author_order: @article_author.author_order, author_seq: @article_author.author_seq, doi: @article_author.doi, given_name: @article_author.given_name, last_name: @article_author.last_name, orcid: @article_author.orcid, status: @article_author.status } }
    assert_redirected_to article_author_url(@article_author)
  end

  test "should destroy article_author" do
    assert_difference("ArticleAuthor.count", -1) do
      delete article_author_url(@article_author)
    end

    assert_redirected_to article_authors_url
  end
end
