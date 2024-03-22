require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  setup do
    @article = articles(:one)
  end

  test "visiting the index" do
    visit articles_url
    assert_selector "h1", text: "Articles"
  end

  test "should create article" do
    visit articles_url
    click_on "New article"

    fill_in "Abstract", with: @article.abstract
    fill_in "Comment", with: @article.comment
    fill_in "Container title", with: @article.container_title
    fill_in "Doi", with: @article.doi
    fill_in "Issue", with: @article.issue
    fill_in "Journal issue", with: @article.journal_issue
    fill_in "License", with: @article.license
    fill_in "Link", with: @article.link
    fill_in "Page", with: @article.page
    fill_in "Pub ol day", with: @article.pub_ol_day
    fill_in "Pub ol month", with: @article.pub_ol_month
    fill_in "Pub ol year", with: @article.pub_ol_year
    fill_in "Pub print day", with: @article.pub_print_day
    fill_in "Pub print month", with: @article.pub_print_month
    fill_in "Pub print year", with: @article.pub_print_year
    fill_in "Pub type", with: @article.pub_type
    fill_in "Pub year", with: @article.pub_year
    fill_in "Publisher", with: @article.publisher
    fill_in "Referenced by count", with: @article.referenced_by_count
    fill_in "References count", with: @article.references_count
    fill_in "Status", with: @article.status
    fill_in "Title", with: @article.title
    fill_in "Url", with: @article.url
    fill_in "Volume", with: @article.volume
    click_on "Create Article"

    assert_text "Article was successfully created"
    click_on "Back"
  end

  test "should update Article" do
    visit article_url(@article)
    click_on "Edit this article", match: :first

    fill_in "Abstract", with: @article.abstract
    fill_in "Comment", with: @article.comment
    fill_in "Container title", with: @article.container_title
    fill_in "Doi", with: @article.doi
    fill_in "Issue", with: @article.issue
    fill_in "Journal issue", with: @article.journal_issue
    fill_in "License", with: @article.license
    fill_in "Link", with: @article.link
    fill_in "Page", with: @article.page
    fill_in "Pub ol day", with: @article.pub_ol_day
    fill_in "Pub ol month", with: @article.pub_ol_month
    fill_in "Pub ol year", with: @article.pub_ol_year
    fill_in "Pub print day", with: @article.pub_print_day
    fill_in "Pub print month", with: @article.pub_print_month
    fill_in "Pub print year", with: @article.pub_print_year
    fill_in "Pub type", with: @article.pub_type
    fill_in "Pub year", with: @article.pub_year
    fill_in "Publisher", with: @article.publisher
    fill_in "Referenced by count", with: @article.referenced_by_count
    fill_in "References count", with: @article.references_count
    fill_in "Status", with: @article.status
    fill_in "Title", with: @article.title
    fill_in "Url", with: @article.url
    fill_in "Volume", with: @article.volume
    click_on "Update Article"

    assert_text "Article was successfully updated"
    click_on "Back"
  end

  test "should destroy Article" do
    visit article_url(@article)
    click_on "Destroy this article", match: :first

    assert_text "Article was successfully destroyed"
  end
end
