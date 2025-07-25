require "application_system_test_case"

class OrganisationAliasesTest < ApplicationSystemTestCase
  setup do
    @organisation_alias = organisation_aliases(:one)
  end

  test "visiting the index" do
    visit organisation_aliases_url
    assert_selector "h1", text: "Organisation aliases"
  end

  test "should create organisation alias" do
    visit organisation_aliases_url
    click_on "New organisation alias"

    fill_in "Alias type", with: @organisation_alias.alias_type
    fill_in "Laguage code", with: @organisation_alias.laguage_code
    fill_in "Name", with: @organisation_alias.name
    fill_in "Organisation", with: @organisation_alias.organisation_id
    fill_in "Valid from", with: @organisation_alias.valid_from
    fill_in "Valid to", with: @organisation_alias.valid_to
    click_on "Create Organisation alias"

    assert_text "Organisation alias was successfully created"
    click_on "Back"
  end

  test "should update Organisation alias" do
    visit organisation_alias_url(@organisation_alias)
    click_on "Edit this organisation alias", match: :first

    fill_in "Alias type", with: @organisation_alias.alias_type
    fill_in "Laguage code", with: @organisation_alias.laguage_code
    fill_in "Name", with: @organisation_alias.name
    fill_in "Organisation", with: @organisation_alias.organisation_id
    fill_in "Valid from", with: @organisation_alias.valid_from
    fill_in "Valid to", with: @organisation_alias.valid_to
    click_on "Update Organisation alias"

    assert_text "Organisation alias was successfully updated"
    click_on "Back"
  end

  test "should destroy Organisation alias" do
    visit organisation_alias_url(@organisation_alias)
    click_on "Destroy this organisation alias", match: :first

    assert_text "Organisation alias was successfully destroyed"
  end
end
