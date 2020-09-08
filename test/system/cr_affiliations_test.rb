require "application_system_test_case"

class CrAffiliationsTest < ApplicationSystemTestCase
  setup do
    @cr_affiliation = cr_affiliations(:one)
  end

  test "visiting the index" do
    visit cr_affiliations_url
    assert_selector "h1", text: "Cr Affiliations"
  end

  test "creating a Cr affiliation" do
    visit cr_affiliations_url
    click_on "New Cr Affiliation"

    fill_in "Affiliation", with: @cr_affiliation.affiliation_id
    fill_in "Article author", with: @cr_affiliation.article_author_id
    fill_in "Name", with: @cr_affiliation.name
    click_on "Create Cr affiliation"

    assert_text "Cr affiliation was successfully created"
    click_on "Back"
  end

  test "updating a Cr affiliation" do
    visit cr_affiliations_url
    click_on "Edit", match: :first

    fill_in "Affiliation", with: @cr_affiliation.affiliation_id
    fill_in "Article author", with: @cr_affiliation.article_author_id
    fill_in "Name", with: @cr_affiliation.name
    click_on "Update Cr affiliation"

    assert_text "Cr affiliation was successfully updated"
    click_on "Back"
  end

  test "destroying a Cr affiliation" do
    visit cr_affiliations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Cr affiliation was successfully destroyed"
  end
end
