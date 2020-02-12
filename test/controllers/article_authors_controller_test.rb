require 'test_helper'

class ArticleAuthorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article_author = article_authors(:one)
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
    assert_difference('ArticleAuthor.count') do
      post article_authors_url, params: { article_author: { article_id: @article_author.article_id, author_count: @article_author.author_count, author_id: @article_author.author_id, author_order: @article_author.author_order, doi: @article_author.doi, sequence: @article_author.sequence, status: @article_author.status } }
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
    patch article_author_url(@article_author), params: { article_author: { article_id: @article_author.article_id, author_count: @article_author.author_count, author_id: @article_author.author_id, author_order: @article_author.author_order, doi: @article_author.doi, sequence: @article_author.sequence, status: @article_author.status } }
    assert_redirected_to article_author_url(@article_author)
  end

  test "should destroy article_author" do
    assert_difference('ArticleAuthor.count', -1) do
      delete article_author_url(@article_author)
    end

    assert_redirected_to article_authors_url
  end
end
