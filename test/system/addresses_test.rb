require "application_system_test_case"

class AddressesTest < ApplicationSystemTestCase
  setup do
    @address = addresses(:one)
  end

  test "visiting the index" do
    visit addresses_url
    assert_selector "h1", text: "Addresses"
  end

  test "creating a Address" do
    visit addresses_url
    click_on "New Address"

    fill_in "Add 01", with: @address.add_01
    fill_in "Add 02", with: @address.add_02
    fill_in "Add 03", with: @address.add_03
    fill_in "Add 04", with: @address.add_04
    fill_in "Affiliation", with: @address.affiliation_id
    fill_in "Country", with: @address.country
    click_on "Create Address"

    assert_text "Address was successfully created"
    click_on "Back"
  end

  test "updating a Address" do
    visit addresses_url
    click_on "Edit", match: :first

    fill_in "Add 01", with: @address.add_01
    fill_in "Add 02", with: @address.add_02
    fill_in "Add 03", with: @address.add_03
    fill_in "Add 04", with: @address.add_04
    fill_in "Affiliation", with: @address.affiliation_id
    fill_in "Country", with: @address.country
    click_on "Update Address"

    assert_text "Address was successfully updated"
    click_on "Back"
  end

  test "destroying a Address" do
    visit addresses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Address was successfully destroyed"
  end
end
