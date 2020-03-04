require "application_system_test_case"

class ArticleDatasetsTest < ApplicationSystemTestCase
  setup do
    @article_dataset = article_datasets(:one)
  end

  test "visiting the index" do
    visit article_datasets_url
    assert_selector "h1", text: "Article Datasets"
  end

  test "creating a Article dataset" do
    visit article_datasets_url
    click_on "New Article Dataset"

    fill_in "Article", with: @article_dataset.article_id
    fill_in "Dataset", with: @article_dataset.dataset_id
    fill_in "Doi", with: @article_dataset.doi
    click_on "Create Article dataset"

    assert_text "Article dataset was successfully created"
    click_on "Back"
  end

  test "updating a Article dataset" do
    visit article_datasets_url
    click_on "Edit", match: :first

    fill_in "Article", with: @article_dataset.article_id
    fill_in "Dataset", with: @article_dataset.dataset_id
    fill_in "Doi", with: @article_dataset.doi
    click_on "Update Article dataset"

    assert_text "Article dataset was successfully updated"
    click_on "Back"
  end

  test "destroying a Article dataset" do
    visit article_datasets_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Article dataset was successfully destroyed"
  end
end
