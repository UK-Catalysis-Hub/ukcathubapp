require "test_helper"

class AuthorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @author = authors(:one)
  end

  test "should get index" do
    get authors_url
    assert_response :success
  end

  test "should get new" do
    get new_author_url
    assert_response :success
  end

  test "should create author" do
    assert_difference("Author.count") do
      post authors_url, params: { author: { given_name: @author.given_name, isap: @author.isap, last_name: @author.last_name, orcid: @author.orcid } }
    end

    assert_redirected_to author_url(Author.last)
  end

  test "should show author" do
    get author_url(@author)
    assert_response :success
  end

  test "should get edit" do
    get edit_author_url(@author)
    assert_response :success
  end

  test "should update author" do
    patch author_url(@author), params: { author: { given_name: @author.given_name, isap: @author.isap, last_name: @author.last_name, orcid: @author.orcid } }
    assert_redirected_to author_url(@author)
  end

  test "should destroy author" do
    assert_difference("Author.count", -1) do
      delete author_url(@author)
    end
    assert_redirected_to authors_url
  end
end
