require "application_system_test_case"

class ArticleAuthorsTest < ApplicationSystemTestCase
  setup do
    @article_author = article_authors(:one)
  end

  test "visiting the index" do
    visit article_authors_url
    assert_selector "h1", text: "Article authors"
  end

  test "should create article author" do
    visit article_authors_url
    click_on "New article author"

    fill_in "Article", with: @article_author.article_id
    fill_in "Author count", with: @article_author.author_count
    fill_in "Author", with: @article_author.author_id
    fill_in "Author order", with: @article_author.author_order
    fill_in "Author seq", with: @article_author.author_seq
    fill_in "Doi", with: @article_author.doi
    fill_in "Given name", with: @article_author.given_name
    fill_in "Last name", with: @article_author.last_name
    fill_in "Orcid", with: @article_author.orcid
    fill_in "Status", with: @article_author.status
    click_on "Create Article author"

    assert_text "Article author was successfully created"
    click_on "Back"
  end

  test "should update Article author" do
    visit article_author_url(@article_author)
    click_on "Edit this article author", match: :first

    fill_in "Article", with: @article_author.article_id
    fill_in "Author count", with: @article_author.author_count
    fill_in "Author", with: @article_author.author_id
    fill_in "Author order", with: @article_author.author_order
    fill_in "Author seq", with: @article_author.author_seq
    fill_in "Doi", with: @article_author.doi
    fill_in "Given name", with: @article_author.given_name
    fill_in "Last name", with: @article_author.last_name
    fill_in "Orcid", with: @article_author.orcid
    fill_in "Status", with: @article_author.status
    click_on "Update Article author"

    assert_text "Article author was successfully updated"
    click_on "Back"
  end

  test "should destroy Article author" do
    visit article_author_url(@article_author)
    click_on "Destroy this article author", match: :first

    assert_text "Article author was successfully destroyed"
  end
end
