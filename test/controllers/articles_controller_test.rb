require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
  end

  test "should get index" do
    get articles_url
    assert_response :success
  end

  test "should get new" do
    get new_article_url
    assert_response :success
  end

  test "should create article" do
    assert_difference("Article.count") do
      post articles_url, params: { article: { abstract: @article.abstract, comment: @article.comment, container_title: @article.container_title, doi: @article.doi, issue: @article.issue, journal_issue: @article.journal_issue, license: @article.license, link: @article.link, page: @article.page, pub_ol_day: @article.pub_ol_day, pub_ol_month: @article.pub_ol_month, pub_ol_year: @article.pub_ol_year, pub_print_day: @article.pub_print_day, pub_print_month: @article.pub_print_month, pub_print_year: @article.pub_print_year, pub_type: @article.pub_type, pub_year: @article.pub_year, publisher: @article.publisher, referenced_by_count: @article.referenced_by_count, references_count: @article.references_count, status: @article.status, title: @article.title, url: @article.url, volume: @article.volume } }
    end

    assert_redirected_to article_url(Article.last)
  end

  test "should show article" do
    get article_url(@article)
    assert_response :success
  end

  test "should get edit" do
    get edit_article_url(@article)
    assert_response :success
  end

  test "should update article" do
    patch article_url(@article), params: { article: { abstract: @article.abstract, comment: @article.comment, container_title: @article.container_title, doi: @article.doi, issue: @article.issue, journal_issue: @article.journal_issue, license: @article.license, link: @article.link, page: @article.page, pub_ol_day: @article.pub_ol_day, pub_ol_month: @article.pub_ol_month, pub_ol_year: @article.pub_ol_year, pub_print_day: @article.pub_print_day, pub_print_month: @article.pub_print_month, pub_print_year: @article.pub_print_year, pub_type: @article.pub_type, pub_year: @article.pub_year, publisher: @article.publisher, referenced_by_count: @article.referenced_by_count, references_count: @article.references_count, status: @article.status, title: @article.title, url: @article.url, volume: @article.volume } }
    assert_redirected_to article_url(@article)
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_url
  end
end
