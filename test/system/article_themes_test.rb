require "application_system_test_case"

class ArticleThemesTest < ApplicationSystemTestCase
  setup do
    @article_theme = article_themes(:one)
  end

  test "visiting the index" do
    visit article_themes_url
    assert_selector "h1", text: "Article themes"
  end

  test "should create article theme" do
    visit article_themes_url
    click_on "New article theme"

    fill_in "Article", with: @article_theme.article_id
    fill_in "Collaboration", with: @article_theme.collaboration
    fill_in "Doi", with: @article_theme.doi
    fill_in "Phase", with: @article_theme.phase
    fill_in "Project year", with: @article_theme.project_year
    fill_in "Theme", with: @article_theme.theme_id
    click_on "Create Article theme"

    assert_text "Article theme was successfully created"
    click_on "Back"
  end

  test "should update Article theme" do
    visit article_theme_url(@article_theme)
    click_on "Edit this article theme", match: :first

    fill_in "Article", with: @article_theme.article_id
    fill_in "Collaboration", with: @article_theme.collaboration
    fill_in "Doi", with: @article_theme.doi
    fill_in "Phase", with: @article_theme.phase
    fill_in "Project year", with: @article_theme.project_year
    fill_in "Theme", with: @article_theme.theme_id
    click_on "Update Article theme"

    assert_text "Article theme was successfully updated"
    click_on "Back"
  end

  test "should destroy Article theme" do
    visit article_theme_url(@article_theme)
    click_on "Destroy this article theme", match: :first

    assert_text "Article theme was successfully destroyed"
  end
end
