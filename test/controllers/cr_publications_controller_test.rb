require "test_helper"

class CrPublicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @cr_publication = cr_publications(:one)
  end

  test "should get index" do
    get cr_publications_url
    assert_response :success
  end

  test "should get new" do
    get new_cr_publication_url
    assert_response :success
  end

  test "should create cr_publication" do
    assert_difference("CrPublication.count") do
      post cr_publications_url, params: { cr_publication: { authors: @cr_publication.authors, awards: @cr_publication.awards, doi: @cr_publication.doi, note: @cr_publication.note, pub_year: @cr_publication.pub_year, status: @cr_publication.status, themes: @cr_publication.themes, title: @cr_publication.title, xref_affi: @cr_publication.xref_affi } }
    end

    assert_redirected_to cr_publication_url(CrPublication.last)
  end

  test "should show cr_publication" do
    get cr_publication_url(@cr_publication)
    assert_response :success
  end

  test "should get edit" do
    get edit_cr_publication_url(@cr_publication)
    assert_response :success
  end

  test "should update cr_publication" do
    patch cr_publication_url(@cr_publication), params: { cr_publication: { authors: @cr_publication.authors, awards: @cr_publication.awards, doi: @cr_publication.doi, note: @cr_publication.note, pub_year: @cr_publication.pub_year, status: @cr_publication.status, themes: @cr_publication.themes, title: @cr_publication.title, xref_affi: @cr_publication.xref_affi } }
    assert_redirected_to cr_publication_url(@cr_publication)
  end

  test "should destroy cr_publication" do
    assert_difference("CrPublication.count", -1) do
      delete cr_publication_url(@cr_publication)
    end

    assert_redirected_to cr_publications_url
  end
end
