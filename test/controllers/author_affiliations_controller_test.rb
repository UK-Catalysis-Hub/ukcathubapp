require 'test_helper'

class AuthorAffiliationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author_affiliation = author_affiliations(:one)
  end

  test "should get index" do
    get author_affiliations_url
    assert_response :success
  end

  test "should get new" do
    get new_author_affiliation_url
    assert_response :success
  end

  test "should create author_affiliation" do
    assert_difference('AuthorAffiliation.count') do
      post author_affiliations_url, params: { author_affiliation: { add_01: @author_affiliation.add_01, add_02: @author_affiliation.add_02, add_03: @author_affiliation.add_03, add_04: @author_affiliation.add_04, add_05: @author_affiliation.add_05, author_id: @author_affiliation.author_id, country: @author_affiliation.country, name: @author_affiliation.name } }
    end

    assert_redirected_to author_affiliation_url(AuthorAffiliation.last)
  end

  test "should show author_affiliation" do
    get author_affiliation_url(@author_affiliation)
    assert_response :success
  end

  test "should get edit" do
    get edit_author_affiliation_url(@author_affiliation)
    assert_response :success
  end

  test "should update author_affiliation" do
    patch author_affiliation_url(@author_affiliation), params: { author_affiliation: { add_01: @author_affiliation.add_01, add_02: @author_affiliation.add_02, add_03: @author_affiliation.add_03, add_04: @author_affiliation.add_04, add_05: @author_affiliation.add_05, author_id: @author_affiliation.author_id, country: @author_affiliation.country, name: @author_affiliation.name } }
    assert_redirected_to author_affiliation_url(@author_affiliation)
  end

  test "should destroy author_affiliation" do
    assert_difference('AuthorAffiliation.count', -1) do
      delete author_affiliation_url(@author_affiliation)
    end

    assert_redirected_to author_affiliations_url
  end
end
