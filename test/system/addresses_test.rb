require "application_system_test_case"

class AddressesTest < ApplicationSystemTestCase
  setup do
    @address = addresses(:one)
  end

  test "visiting the index" do
    visit addresses_url
    assert_selector "h1", text: "Addresses"
  end

  test "should create address" do
    visit addresses_url
    click_on "New address"

    fill_in "Add 01", with: @address.add_01
    fill_in "Add 02", with: @address.add_02
    fill_in "Add 03", with: @address.add_03
    fill_in "Add 04", with: @address.add_04
    fill_in "Affiliation", with: @address.affiliation_id
    fill_in "City", with: @address.city
    fill_in "Country", with: @address.country
    fill_in "Province", with: @address.province
    click_on "Create Address"

    assert_text "Address was successfully created"
    click_on "Back"
  end

  test "should update Address" do
    visit address_url(@address)
    click_on "Edit this address", match: :first

    fill_in "Add 01", with: @address.add_01
    fill_in "Add 02", with: @address.add_02
    fill_in "Add 03", with: @address.add_03
    fill_in "Add 04", with: @address.add_04
    fill_in "Affiliation", with: @address.affiliation_id
    fill_in "City", with: @address.city
    fill_in "Country", with: @address.country
    fill_in "Province", with: @address.province
    click_on "Update Address"

    assert_text "Address was successfully updated"
    click_on "Back"
  end

  test "should destroy Address" do
    visit address_url(@address)
    click_on "Destroy this address", match: :first

    assert_text "Address was successfully destroyed"
  end
end
