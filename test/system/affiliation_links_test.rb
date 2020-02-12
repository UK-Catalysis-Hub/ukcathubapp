require "application_system_test_case"

class AffiliationLinksTest < ApplicationSystemTestCase
  setup do
    @affiliation_link = affiliation_links(:one)
  end

  test "visiting the index" do
    visit affiliation_links_url
    assert_selector "h1", text: "Affiliation Links"
  end

  test "creating a Affiliation link" do
    visit affiliation_links_url
    click_on "New Affiliation Link"

    fill_in "Address", with: @affiliation_link.address_id
    fill_in "Affiliation", with: @affiliation_link.affiliation_id
    fill_in "Author", with: @affiliation_link.author_id
    fill_in "Doi", with: @affiliation_link.doi
    fill_in "Sequence", with: @affiliation_link.sequence
    click_on "Create Affiliation link"

    assert_text "Affiliation link was successfully created"
    click_on "Back"
  end

  test "updating a Affiliation link" do
    visit affiliation_links_url
    click_on "Edit", match: :first

    fill_in "Address", with: @affiliation_link.address_id
    fill_in "Affiliation", with: @affiliation_link.affiliation_id
    fill_in "Author", with: @affiliation_link.author_id
    fill_in "Doi", with: @affiliation_link.doi
    fill_in "Sequence", with: @affiliation_link.sequence
    click_on "Update Affiliation link"

    assert_text "Affiliation link was successfully updated"
    click_on "Back"
  end

  test "destroying a Affiliation link" do
    visit affiliation_links_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Affiliation link was successfully destroyed"
  end
end
