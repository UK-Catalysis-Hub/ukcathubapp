require 'test_helper'

class ArticleDatasetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article_dataset = article_datasets(:one)
  end

  test "should get index" do
    get article_datasets_url
    assert_response :success
  end

  test "should get new" do
    get new_article_dataset_url
    assert_response :success
  end

  test "should create article_dataset" do
    assert_difference('ArticleDataset.count') do
      post article_datasets_url, params: { article_dataset: { article_id: @article_dataset.article_id, dataset_id: @article_dataset.dataset_id, doi: @article_dataset.doi } }
    end

    assert_redirected_to article_dataset_url(ArticleDataset.last)
  end

  test "should show article_dataset" do
    get article_dataset_url(@article_dataset)
    assert_response :success
  end

  test "should get edit" do
    get edit_article_dataset_url(@article_dataset)
    assert_response :success
  end

  test "should update article_dataset" do
    patch article_dataset_url(@article_dataset), params: { article_dataset: { article_id: @article_dataset.article_id, dataset_id: @article_dataset.dataset_id, doi: @article_dataset.doi } }
    assert_redirected_to article_dataset_url(@article_dataset)
  end

  test "should destroy article_dataset" do
    assert_difference('ArticleDataset.count', -1) do
      delete article_dataset_url(@article_dataset)
    end

    assert_redirected_to article_datasets_url
  end
end
