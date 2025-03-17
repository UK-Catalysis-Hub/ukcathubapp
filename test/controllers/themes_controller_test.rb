require "test_helper"

class ThemesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @theme = themes(:one)
  end

  test "should get index" do
    get themes_url
    assert_response :success
  end

  test "should get new" do
    get new_theme_url
    assert_response :success
  end

  test "should create theme" do
    assert_difference("Theme.count") do
      post themes_url, params: { theme: { lead: @theme.lead, name: @theme.name, phase: @theme.phase, short: @theme.short, used: @theme.used } }
    end

    assert_redirected_to theme_url(Theme.last)
  end

  test "should show theme" do
    get theme_url(@theme)
    assert_response :success
  end

  test "should get edit" do
    get edit_theme_url(@theme)
    assert_response :success
  end

  test "should update theme" do
    patch theme_url(@theme), params: { theme: { lead: @theme.lead, name: @theme.name, phase: @theme.phase, short: @theme.short, used: @theme.used } }
    assert_redirected_to theme_url(@theme)
  end

  test "should destroy theme" do
    assert_difference("Theme.count", -1) do
      delete theme_url(@theme)
    end

    assert_redirected_to themes_url
  end
end
