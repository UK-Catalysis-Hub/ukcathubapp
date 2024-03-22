require "application_system_test_case"

class AuthorAffiliationsTest < ApplicationSystemTestCase
  setup do
    @author_affiliation = author_affiliations(:one)
  end

  test "visiting the index" do
    visit author_affiliations_url
    assert_selector "h1", text: "Author affiliations"
  end

  test "should create author affiliation" do
    visit author_affiliations_url
    click_on "New author affiliation"

    fill_in "Add 01", with: @author_affiliation.add_01
    fill_in "Add 02", with: @author_affiliation.add_02
    fill_in "Add 03", with: @author_affiliation.add_03
    fill_in "Add 04", with: @author_affiliation.add_04
    fill_in "Add 05", with: @author_affiliation.add_05
    fill_in "Affiliation", with: @author_affiliation.affiliation_id
    fill_in "Article author", with: @author_affiliation.article_author_id
    fill_in "City", with: @author_affiliation.city
    fill_in "Country", with: @author_affiliation.country
    fill_in "Name", with: @author_affiliation.name
    fill_in "Province", with: @author_affiliation.province
    fill_in "Short name", with: @author_affiliation.short_name
    click_on "Create Author affiliation"

    assert_text "Author affiliation was successfully created"
    click_on "Back"
  end

  test "should update Author affiliation" do
    visit author_affiliation_url(@author_affiliation)
    click_on "Edit this author affiliation", match: :first

    fill_in "Add 01", with: @author_affiliation.add_01
    fill_in "Add 02", with: @author_affiliation.add_02
    fill_in "Add 03", with: @author_affiliation.add_03
    fill_in "Add 04", with: @author_affiliation.add_04
    fill_in "Add 05", with: @author_affiliation.add_05
    fill_in "Affiliation", with: @author_affiliation.affiliation_id
    fill_in "Article author", with: @author_affiliation.article_author_id
    fill_in "City", with: @author_affiliation.city
    fill_in "Country", with: @author_affiliation.country
    fill_in "Name", with: @author_affiliation.name
    fill_in "Province", with: @author_affiliation.province
    fill_in "Short name", with: @author_affiliation.short_name
    click_on "Update Author affiliation"

    assert_text "Author affiliation was successfully updated"
    click_on "Back"
  end

  test "should destroy Author affiliation" do
    visit author_affiliation_url(@author_affiliation)
    click_on "Destroy this author affiliation", match: :first

    assert_text "Author affiliation was successfully destroyed"
  end
end
