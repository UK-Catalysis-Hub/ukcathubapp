require "application_system_test_case"

class AuthorAffiliationsTest < ApplicationSystemTestCase
  setup do
    @author_affiliation = author_affiliations(:one)
  end

  test "visiting the index" do
    visit author_affiliations_url
    assert_selector "h1", text: "Author Affiliations"
  end

  test "creating a Author affiliation" do
    visit author_affiliations_url
    click_on "New Author Affiliation"

    fill_in "Add 01", with: @author_affiliation.add_01
    fill_in "Add 02", with: @author_affiliation.add_02
    fill_in "Add 03", with: @author_affiliation.add_03
    fill_in "Add 04", with: @author_affiliation.add_04
    fill_in "Add 05", with: @author_affiliation.add_05
    fill_in "Author", with: @author_affiliation.author_id
    fill_in "Country", with: @author_affiliation.country
    fill_in "Name", with: @author_affiliation.name
    click_on "Create Author affiliation"

    assert_text "Author affiliation was successfully created"
    click_on "Back"
  end

  test "updating a Author affiliation" do
    visit author_affiliations_url
    click_on "Edit", match: :first

    fill_in "Add 01", with: @author_affiliation.add_01
    fill_in "Add 02", with: @author_affiliation.add_02
    fill_in "Add 03", with: @author_affiliation.add_03
    fill_in "Add 04", with: @author_affiliation.add_04
    fill_in "Add 05", with: @author_affiliation.add_05
    fill_in "Author", with: @author_affiliation.author_id
    fill_in "Country", with: @author_affiliation.country
    fill_in "Name", with: @author_affiliation.name
    click_on "Update Author affiliation"

    assert_text "Author affiliation was successfully updated"
    click_on "Back"
  end

  test "destroying a Author affiliation" do
    visit author_affiliations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Author affiliation was successfully destroyed"
  end
end
