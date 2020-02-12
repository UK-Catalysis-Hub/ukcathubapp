require "application_system_test_case"

class ThemesTest < ApplicationSystemTestCase
  setup do
    @theme = themes(:one)
  end

  test "visiting the index" do
    visit themes_url
    assert_selector "h1", text: "Themes"
  end

  test "creating a Theme" do
    visit themes_url
    click_on "New Theme"

    fill_in "Lead", with: @theme.lead
    fill_in "Name", with: @theme.name
    fill_in "Phase", with: @theme.phase
    fill_in "Short", with: @theme.short
    fill_in "Used", with: @theme.used
    click_on "Create Theme"

    assert_text "Theme was successfully created"
    click_on "Back"
  end

  test "updating a Theme" do
    visit themes_url
    click_on "Edit", match: :first

    fill_in "Lead", with: @theme.lead
    fill_in "Name", with: @theme.name
    fill_in "Phase", with: @theme.phase
    fill_in "Short", with: @theme.short
    fill_in "Used", with: @theme.used
    click_on "Update Theme"

    assert_text "Theme was successfully updated"
    click_on "Back"
  end

  test "destroying a Theme" do
    visit themes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Theme was successfully destroyed"
  end
end
