require "test_helper"

class ArticleThemesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @article_theme = article_themes(:one)
    # ids should not be empty "for belongs" to relationships
    @article_theme.theme_id = themes(:one).id
    @article_theme.article_id = articles(:one).id
  end

  test "should get index" do
    get article_themes_url
    assert_response :success
  end

  test "should get new" do
    get new_article_theme_url
    assert_response :success
  end

  test "should create article_theme" do
    assert_difference("ArticleTheme.count") do
      post article_themes_url, params: { article_theme: { article_id: @article_theme.article_id, collaboration: @article_theme.collaboration, doi: @article_theme.doi, phase: @article_theme.phase, project_year: @article_theme.project_year, theme_id: @article_theme.theme_id } }
    end

    assert_redirected_to article_theme_url(ArticleTheme.last)
  end

  test "should show article_theme" do
    get article_theme_url(@article_theme)
    assert_response :success
  end

  test "should get edit" do
    get edit_article_theme_url(@article_theme)
    assert_response :success
  end

  test "should update article_theme" do
    patch article_theme_url(@article_theme), params: { article_theme: { article_id: @article_theme.article_id, collaboration: @article_theme.collaboration, doi: @article_theme.doi, phase: @article_theme.phase, project_year: @article_theme.project_year, theme_id: @article_theme.theme_id } }
    assert_redirected_to article_theme_url(@article_theme)
  end

  test "should destroy article_theme" do
    assert_difference("ArticleTheme.count", -1) do
      delete article_theme_url(@article_theme)
    end

    assert_redirected_to article_themes_url
  end
end
