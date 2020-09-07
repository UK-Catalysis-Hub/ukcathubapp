require "application_system_test_case"

class CrAfiliationsTest < ApplicationSystemTestCase
  setup do
    @cr_afiliation = cr_afiliations(:one)
  end

  test "visiting the index" do
    visit cr_afiliations_url
    assert_selector "h1", text: "Cr Afiliations"
  end

  test "creating a Cr afiliation" do
    visit cr_afiliations_url
    click_on "New Cr Afiliation"

    fill_in "Affiliation", with: @cr_afiliation.affiliation_id
    fill_in "Article author", with: @cr_afiliation.article_author_id
    fill_in "Name", with: @cr_afiliation.name
    click_on "Create Cr afiliation"

    assert_text "Cr afiliation was successfully created"
    click_on "Back"
  end

  test "updating a Cr afiliation" do
    visit cr_afiliations_url
    click_on "Edit", match: :first

    fill_in "Affiliation", with: @cr_afiliation.affiliation_id
    fill_in "Article author", with: @cr_afiliation.article_author_id
    fill_in "Name", with: @cr_afiliation.name
    click_on "Update Cr afiliation"

    assert_text "Cr afiliation was successfully updated"
    click_on "Back"
  end

  test "destroying a Cr afiliation" do
    visit cr_afiliations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Cr afiliation was successfully destroyed"
  end
end
