require "application_system_test_case"

class AffiliationsTest < ApplicationSystemTestCase
  setup do
    @affiliation = affiliations(:one)
  end

  test "visiting the index" do
    visit affiliations_url
    assert_selector "h1", text: "Affiliations"
  end

  test "should create affiliation" do
    visit affiliations_url
    click_on "New affiliation"

    fill_in "Country", with: @affiliation.country
    fill_in "Department", with: @affiliation.department
    fill_in "Faculty", with: @affiliation.faculty
    fill_in "Institution", with: @affiliation.institution
    fill_in "School", with: @affiliation.school
    fill_in "Sector", with: @affiliation.sector
    fill_in "Work group", with: @affiliation.work_group
    click_on "Create Affiliation"

    assert_text "Affiliation was successfully created"
    click_on "Back"
  end

  test "should update Affiliation" do
    visit affiliation_url(@affiliation)
    click_on "Edit this affiliation", match: :first

    fill_in "Country", with: @affiliation.country
    fill_in "Department", with: @affiliation.department
    fill_in "Faculty", with: @affiliation.faculty
    fill_in "Institution", with: @affiliation.institution
    fill_in "School", with: @affiliation.school
    fill_in "Sector", with: @affiliation.sector
    fill_in "Work group", with: @affiliation.work_group
    click_on "Update Affiliation"

    assert_text "Affiliation was successfully updated"
    click_on "Back"
  end

  test "should destroy Affiliation" do
    visit affiliation_url(@affiliation)
    click_on "Destroy this affiliation", match: :first

    assert_text "Affiliation was successfully destroyed"
  end
end
