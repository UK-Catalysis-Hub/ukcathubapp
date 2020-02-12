require "application_system_test_case"

class ArticleThemesTest < ApplicationSystemTestCase
  setup do
    @article_theme = article_themes(:one)
  end

  test "visiting the index" do
    visit article_themes_url
    assert_selector "h1", text: "Article Themes"
  end

  test "creating a Article theme" do
    visit article_themes_url
    click_on "New Article Theme"

    fill_in "Collaboration", with: @article_theme.collaboration
    fill_in "Doi", with: @article_theme.doi
    fill_in "Phase", with: @article_theme.phase
    fill_in "Project year", with: @article_theme.project_year
    fill_in "Theme", with: @article_theme.theme_id
    click_on "Create Article theme"

    assert_text "Article theme was successfully created"
    click_on "Back"
  end

  test "updating a Article theme" do
    visit article_themes_url
    click_on "Edit", match: :first

    fill_in "Collaboration", with: @article_theme.collaboration
    fill_in "Doi", with: @article_theme.doi
    fill_in "Phase", with: @article_theme.phase
    fill_in "Project year", with: @article_theme.project_year
    fill_in "Theme", with: @article_theme.theme_id
    click_on "Update Article theme"

    assert_text "Article theme was successfully updated"
    click_on "Back"
  end

  test "destroying a Article theme" do
    visit article_themes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Article theme was successfully destroyed"
  end
end
