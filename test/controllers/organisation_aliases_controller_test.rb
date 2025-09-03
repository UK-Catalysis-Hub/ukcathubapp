require "test_helper"

class OrganisationAliasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organisation_alias = organisation_aliases(:orgalione)
  end

  test "should get index" do
    get organisation_aliases_url
    assert_response :success
  end

  test "should get new" do
    get new_organisation_alias_url
    assert_response :success
  end

  test "should create organisation_alias" do
    assert_difference("OrganisationAlias.count") do
      post organisation_aliases_url, params: { organisation_alias: { alias_type: @organisation_alias.alias_type, laguage_code: @organisation_alias.laguage_code, name: @organisation_alias.name, organisation_id: @organisation_alias.organisation_id, valid_from: @organisation_alias.valid_from, valid_to: @organisation_alias.valid_to } }
    end

    assert_redirected_to organisation_alias_url(OrganisationAlias.last)
  end

  test "should show organisation_alias" do
    get organisation_alias_url(@organisation_alias)
    assert_response :success
  end

  test "should get edit" do
    get edit_organisation_alias_url(@organisation_alias)
    assert_response :success
  end

  test "should update organisation_alias" do
    patch organisation_alias_url(@organisation_alias), params: { organisation_alias: { alias_type: @organisation_alias.alias_type, laguage_code: @organisation_alias.laguage_code, name: @organisation_alias.name, organisation_id: @organisation_alias.organisation_id, valid_from: @organisation_alias.valid_from, valid_to: @organisation_alias.valid_to } }
    assert_redirected_to organisation_alias_url(@organisation_alias)
  end

  test "should destroy organisation_alias" do
    assert_difference("OrganisationAlias.count", -1) do
      delete organisation_alias_url(@organisation_alias)
    end

    assert_redirected_to organisation_aliases_url
  end
end
