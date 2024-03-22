require "application_system_test_case"

class ArticleDatasetsTest < ApplicationSystemTestCase
  setup do
    @article_dataset = article_datasets(:one)
  end

  test "visiting the index" do
    visit article_datasets_url
    assert_selector "h1", text: "Article datasets"
  end

  test "should create article dataset" do
    visit article_datasets_url
    click_on "New article dataset"

    fill_in "Article", with: @article_dataset.article_id
    fill_in "Dataset", with: @article_dataset.dataset_id
    fill_in "Doi", with: @article_dataset.doi
    click_on "Create Article dataset"

    assert_text "Article dataset was successfully created"
    click_on "Back"
  end

  test "should update Article dataset" do
    visit article_dataset_url(@article_dataset)
    click_on "Edit this article dataset", match: :first

    fill_in "Article", with: @article_dataset.article_id
    fill_in "Dataset", with: @article_dataset.dataset_id
    fill_in "Doi", with: @article_dataset.doi
    click_on "Update Article dataset"

    assert_text "Article dataset was successfully updated"
    click_on "Back"
  end

  test "should destroy Article dataset" do
    visit article_dataset_url(@article_dataset)
    click_on "Destroy this article dataset", match: :first

    assert_text "Article dataset was successfully destroyed"
  end
end
