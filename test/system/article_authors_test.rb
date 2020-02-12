require "application_system_test_case"

class ArticleAuthorsTest < ApplicationSystemTestCase
  setup do
    @article_author = article_authors(:one)
  end

  test "visiting the index" do
    visit article_authors_url
    assert_selector "h1", text: "Article Authors"
  end

  test "creating a Article author" do
    visit article_authors_url
    click_on "New Article Author"

    fill_in "Article", with: @article_author.article_id
    fill_in "Author count", with: @article_author.author_count
    fill_in "Author", with: @article_author.author_id
    fill_in "Author order", with: @article_author.author_order
    fill_in "Doi", with: @article_author.doi
    fill_in "Sequence", with: @article_author.sequence
    fill_in "Status", with: @article_author.status
    click_on "Create Article author"

    assert_text "Article author was successfully created"
    click_on "Back"
  end

  test "updating a Article author" do
    visit article_authors_url
    click_on "Edit", match: :first

    fill_in "Article", with: @article_author.article_id
    fill_in "Author count", with: @article_author.author_count
    fill_in "Author", with: @article_author.author_id
    fill_in "Author order", with: @article_author.author_order
    fill_in "Doi", with: @article_author.doi
    fill_in "Sequence", with: @article_author.sequence
    fill_in "Status", with: @article_author.status
    click_on "Update Article author"

    assert_text "Article author was successfully updated"
    click_on "Back"
  end

  test "destroying a Article author" do
    visit article_authors_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Article author was successfully destroyed"
  end
end
