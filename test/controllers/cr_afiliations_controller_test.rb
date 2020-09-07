require 'test_helper'

class CrAfiliationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cr_afiliation = cr_afiliations(:one)
  end

  test "should get index" do
    get cr_afiliations_url
    assert_response :success
  end

  test "should get new" do
    get new_cr_afiliation_url
    assert_response :success
  end

  test "should create cr_afiliation" do
    assert_difference('CrAfiliation.count') do
      post cr_afiliations_url, params: { cr_afiliation: { affiliation_id: @cr_afiliation.affiliation_id, article_author_id: @cr_afiliation.article_author_id, name: @cr_afiliation.name } }
    end

    assert_redirected_to cr_afiliation_url(CrAfiliation.last)
  end

  test "should show cr_afiliation" do
    get cr_afiliation_url(@cr_afiliation)
    assert_response :success
  end

  test "should get edit" do
    get edit_cr_afiliation_url(@cr_afiliation)
    assert_response :success
  end

  test "should update cr_afiliation" do
    patch cr_afiliation_url(@cr_afiliation), params: { cr_afiliation: { affiliation_id: @cr_afiliation.affiliation_id, article_author_id: @cr_afiliation.article_author_id, name: @cr_afiliation.name } }
    assert_redirected_to cr_afiliation_url(@cr_afiliation)
  end

  test "should destroy cr_afiliation" do
    assert_difference('CrAfiliation.count', -1) do
      delete cr_afiliation_url(@cr_afiliation)
    end

    assert_redirected_to cr_afiliations_url
  end
end
