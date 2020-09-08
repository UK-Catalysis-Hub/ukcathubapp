require 'test_helper'

class CrAffiliationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cr_affiliation = cr_affiliations(:one)
  end

  test "should get index" do
    get cr_affiliations_url
    assert_response :success
  end

  test "should get new" do
    get new_cr_affiliation_url
    assert_response :success
  end

  test "should create cr_affiliation" do
    assert_difference('CrAffiliation.count') do
      post cr_affiliations_url, params: { cr_affiliation: { affiliation_id: @cr_affiliation.affiliation_id, article_author_id: @cr_affiliation.article_author_id, name: @cr_affiliation.name } }
    end

    assert_redirected_to cr_affiliation_url(CrAffiliation.last)
  end

  test "should show cr_affiliation" do
    get cr_affiliation_url(@cr_affiliation)
    assert_response :success
  end

  test "should get edit" do
    get edit_cr_affiliation_url(@cr_affiliation)
    assert_response :success
  end

  test "should update cr_affiliation" do
    patch cr_affiliation_url(@cr_affiliation), params: { cr_affiliation: { affiliation_id: @cr_affiliation.affiliation_id, article_author_id: @cr_affiliation.article_author_id, name: @cr_affiliation.name } }
    assert_redirected_to cr_affiliation_url(@cr_affiliation)
  end

  test "should destroy cr_affiliation" do
    assert_difference('CrAffiliation.count', -1) do
      delete cr_affiliation_url(@cr_affiliation)
    end

    assert_redirected_to cr_affiliations_url
  end
end
