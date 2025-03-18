require "test_helper"

class AppConfigsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @app_config = app_configs(:one)
  end

  test "should get edit" do
    get edit_app_config_url(@app_config)
    assert_response :success
  end

  test "should update app_config" do
    patch app_config_url(@app_config), params: { app_config: { award_list: @app_config.award_list, browser_tab_name: @app_config.browser_tab_name, contact_email: @app_config.contact_email, contact_id: @app_config.contact_id, organisation_id: @app_config.organisation_id, synon_list: @app_config.synon_list, title: @app_config.title } }
    assert_redirected_to app_config_url(@app_config)
  end

end
