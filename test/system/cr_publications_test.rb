require "application_system_test_case"

class CrPublicationsTest < ApplicationSystemTestCase
  setup do
    @cr_publication = cr_publications(:one)
  end

  test "visiting the index" do
    visit cr_publications_url
    assert_selector "h1", text: "Cr publications"
  end

  test "should create cr publication" do
    visit cr_publications_url
    click_on "New cr publication"

    fill_in "Authors", with: @cr_publication.authors
    fill_in "Awards", with: @cr_publication.awards
    fill_in "Doi", with: @cr_publication.doi
    fill_in "Note", with: @cr_publication.note
    fill_in "Pub year", with: @cr_publication.pub_year
    fill_in "Status", with: @cr_publication.status
    fill_in "Themes", with: @cr_publication.themes
    fill_in "Title", with: @cr_publication.title
    fill_in "Xref affi", with: @cr_publication.xref_affi
    click_on "Create Cr publication"

    assert_text "Cr publication was successfully created"
    click_on "Back"
  end

  test "should update Cr publication" do
    visit cr_publication_url(@cr_publication)
    click_on "Edit this cr publication", match: :first

    fill_in "Authors", with: @cr_publication.authors
    fill_in "Awards", with: @cr_publication.awards
    fill_in "Doi", with: @cr_publication.doi
    fill_in "Note", with: @cr_publication.note
    fill_in "Pub year", with: @cr_publication.pub_year
    fill_in "Status", with: @cr_publication.status
    fill_in "Themes", with: @cr_publication.themes
    fill_in "Title", with: @cr_publication.title
    fill_in "Xref affi", with: @cr_publication.xref_affi
    click_on "Update Cr publication"

    assert_text "Cr publication was successfully updated"
    click_on "Back"
  end

  test "should destroy Cr publication" do
    visit cr_publication_url(@cr_publication)
    click_on "Destroy this cr publication", match: :first

    assert_text "Cr publication was successfully destroyed"
  end
end
