require "test_helper"

class OrganisationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @organisation = organisations(:one)
  end

  test "should get index" do
    get organisations_url
    assert_response :success
  end

  test "should get new" do
    get new_organisation_url
    assert_response :success
  end

  test "should create organisation" do
    assert_difference("Organisation.count") do
      post organisations_url, params: { organisation: { address_id: @organisation.address_id, homepage: @organisation.homepage, identifier: @organisation.identifier, logo: @organisation.logo, name: @organisation.name, short_name: @organisation.short_name } }
    end

    assert_redirected_to organisation_url(Organisation.last)
  end

  test "should show organisation" do
    get organisation_url(@organisation)
    assert_response :success
  end

  test "should get edit" do
    get edit_organisation_url(@organisation)
    assert_response :success
  end

  test "should update organisation" do
    patch organisation_url(@organisation), params: { organisation: { address_id: @organisation.address_id, homepage: @organisation.homepage, identifier: @organisation.identifier, logo: @organisation.logo, name: @organisation.name, short_name: @organisation.short_name } }
    assert_redirected_to organisation_url(@organisation)
  end

  test "should destroy organisation" do
    assert_difference("Organisation.count", -1) do
      delete organisation_url(@organisation)
    end

    assert_redirected_to organisations_url
  end
end
