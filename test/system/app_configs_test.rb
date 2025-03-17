require "application_system_test_case"

class AppConfigsTest < ApplicationSystemTestCase
  setup do
    @app_config = app_configs(:one)
  end

  test "visiting the index" do
    visit app_configs_url
    assert_selector "h1", text: "App configs"
  end

  test "should create app config" do
    visit app_configs_url
    click_on "New app config"

    fill_in "Award list", with: @app_config.award_list
    fill_in "Browser tab name", with: @app_config.browser_tab_name
    fill_in "Contact email", with: @app_config.contact_email
    fill_in "Contact", with: @app_config.contact_id
    fill_in "Organisation", with: @app_config.organisation_id
    fill_in "Synon list", with: @app_config.synon_list
    fill_in "Title", with: @app_config.title
    click_on "Create App config"

    assert_text "App config was successfully created"
    click_on "Back"
  end

  test "should update App config" do
    visit app_config_url(@app_config)
    click_on "Edit this app config", match: :first

    fill_in "Award list", with: @app_config.award_list
    fill_in "Browser tab name", with: @app_config.browser_tab_name
    fill_in "Contact email", with: @app_config.contact_email
    fill_in "Contact", with: @app_config.contact_id
    fill_in "Organisation", with: @app_config.organisation_id
    fill_in "Synon list", with: @app_config.synon_list
    fill_in "Title", with: @app_config.title
    click_on "Update App config"

    assert_text "App config was successfully updated"
    click_on "Back"
  end

  test "should destroy App config" do
    visit app_config_url(@app_config)
    click_on "Destroy this app config", match: :first

    assert_text "App config was successfully destroyed"
  end
end
