require "application_system_test_case"

class OrganisationsTest < ApplicationSystemTestCase
  setup do
    @organisation = organisations(:one)
  end

  test "visiting the index" do
    visit organisations_url
    assert_selector "h1", text: "Organisations"
  end

  test "should create organisation" do
    visit organisations_url
    click_on "New organisation"

    fill_in "Address", with: @organisation.address_id
    fill_in "Homepage", with: @organisation.homepage
    fill_in "Identifier", with: @organisation.identifier
    fill_in "Logo", with: @organisation.logo
    fill_in "Name", with: @organisation.name
    fill_in "Short name", with: @organisation.short_name
    click_on "Create Organisation"

    assert_text "Organisation was successfully created"
    click_on "Back"
  end

  test "should update Organisation" do
    visit organisation_url(@organisation)
    click_on "Edit this organisation", match: :first

    fill_in "Address", with: @organisation.address_id
    fill_in "Homepage", with: @organisation.homepage
    fill_in "Identifier", with: @organisation.identifier
    fill_in "Logo", with: @organisation.logo
    fill_in "Name", with: @organisation.name
    fill_in "Short name", with: @organisation.short_name
    click_on "Update Organisation"

    assert_text "Organisation was successfully updated"
    click_on "Back"
  end

  test "should destroy Organisation" do
    visit organisation_url(@organisation)
    click_on "Destroy this organisation", match: :first

    assert_text "Organisation was successfully destroyed"
  end
end
