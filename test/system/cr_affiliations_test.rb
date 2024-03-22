require "application_system_test_case"

class CrAffiliationsTest < ApplicationSystemTestCase
  setup do
    @cr_affiliation = cr_affiliations(:one)
  end

  test "visiting the index" do
    visit cr_affiliations_url
    assert_selector "h1", text: "Cr affiliations"
  end

  test "should create cr affiliation" do
    visit cr_affiliations_url
    click_on "New cr affiliation"

    fill_in "Article author", with: @cr_affiliation.article_author_id
    fill_in "Author affiliation", with: @cr_affiliation.author_affiliation_id
    fill_in "Name", with: @cr_affiliation.name
    click_on "Create Cr affiliation"

    assert_text "Cr affiliation was successfully created"
    click_on "Back"
  end

  test "should update Cr affiliation" do
    visit cr_affiliation_url(@cr_affiliation)
    click_on "Edit this cr affiliation", match: :first

    fill_in "Article author", with: @cr_affiliation.article_author_id
    fill_in "Author affiliation", with: @cr_affiliation.author_affiliation_id
    fill_in "Name", with: @cr_affiliation.name
    click_on "Update Cr affiliation"

    assert_text "Cr affiliation was successfully updated"
    click_on "Back"
  end

  test "should destroy Cr affiliation" do
    visit cr_affiliation_url(@cr_affiliation)
    click_on "Destroy this cr affiliation", match: :first

    assert_text "Cr affiliation was successfully destroyed"
  end
end
