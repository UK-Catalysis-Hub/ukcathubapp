require "test_helper"

class AppConfigsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @app_config = app_configs(:one)
  end

  test "should get index" do
    get app_configs_url
    assert_response :success
  end

  test "should get new" do
    get new_app_config_url
    assert_response :success
  end

  test "should create app_config" do
    assert_difference("AppConfig.count") do
      post app_configs_url, params: { app_config: { award_list: @app_config.award_list, browser_tab_name: @app_config.browser_tab_name, contact_email: @app_config.contact_email, contact_id: @app_config.contact_id, organisation_id: @app_config.organisation_id, synon_list: @app_config.synon_list, title: @app_config.title } }
    end

    assert_redirected_to app_config_url(AppConfig.last)
  end

  test "should show app_config" do
    get app_config_url(@app_config)
    assert_response :success
  end

  test "should get edit" do
    get edit_app_config_url(@app_config)
    assert_response :success
  end

  test "should update app_config" do
    patch app_config_url(@app_config), params: { app_config: { award_list: @app_config.award_list, browser_tab_name: @app_config.browser_tab_name, contact_email: @app_config.contact_email, contact_id: @app_config.contact_id, organisation_id: @app_config.organisation_id, synon_list: @app_config.synon_list, title: @app_config.title } }
    assert_redirected_to app_config_url(@app_config)
  end

  test "should destroy app_config" do
    assert_difference("AppConfig.count", -1) do
      delete app_config_url(@app_config)
    end

    assert_redirected_to app_configs_url
  end
end
