require 'test_helper'

class AffiliationLinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @affiliation_link = affiliation_links(:one)
  end

  test "should get index" do
    get affiliation_links_url
    assert_response :success
  end

  test "should get new" do
    get new_affiliation_link_url
    assert_response :success
  end

  test "should create affiliation_link" do
    assert_difference('AffiliationLink.count') do
      post affiliation_links_url, params: { affiliation_link: { address_id: @affiliation_link.address_id, affiliation_id: @affiliation_link.affiliation_id, author_id: @affiliation_link.author_id, doi: @affiliation_link.doi, sequence: @affiliation_link.sequence } }
    end

    assert_redirected_to affiliation_link_url(AffiliationLink.last)
  end

  test "should show affiliation_link" do
    get affiliation_link_url(@affiliation_link)
    assert_response :success
  end

  test "should get edit" do
    get edit_affiliation_link_url(@affiliation_link)
    assert_response :success
  end

  test "should update affiliation_link" do
    patch affiliation_link_url(@affiliation_link), params: { affiliation_link: { address_id: @affiliation_link.address_id, affiliation_id: @affiliation_link.affiliation_id, author_id: @affiliation_link.author_id, doi: @affiliation_link.doi, sequence: @affiliation_link.sequence } }
    assert_redirected_to affiliation_link_url(@affiliation_link)
  end

  test "should destroy affiliation_link" do
    assert_difference('AffiliationLink.count', -1) do
      delete affiliation_link_url(@affiliation_link)
    end

    assert_redirected_to affiliation_links_url
  end
end
