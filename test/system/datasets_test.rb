require "application_system_test_case"

class DatasetsTest < ApplicationSystemTestCase
  setup do
    @dataset = datasets(:one)
  end

  test "visiting the index" do
    visit datasets_url
    assert_selector "h1", text: "Datasets"
  end

  test "should create dataset" do
    visit datasets_url
    click_on "New dataset"

    fill_in "Complete", with: @dataset.complete
    fill_in "Description", with: @dataset.description
    fill_in "Doi", with: @dataset.doi
    fill_in "Ds type", with: @dataset.ds_type
    fill_in "Enddate", with: @dataset.enddate
    fill_in "Location", with: @dataset.location
    fill_in "Name", with: @dataset.name
    fill_in "Repository", with: @dataset.repository
    fill_in "Startdate", with: @dataset.startdate
    click_on "Create Dataset"

    assert_text "Dataset was successfully created"
    click_on "Back"
  end

  test "should update Dataset" do
    visit dataset_url(@dataset)
    click_on "Edit this dataset", match: :first

    fill_in "Complete", with: @dataset.complete
    fill_in "Description", with: @dataset.description
    fill_in "Doi", with: @dataset.doi
    fill_in "Ds type", with: @dataset.ds_type
    fill_in "Enddate", with: @dataset.enddate
    fill_in "Location", with: @dataset.location
    fill_in "Name", with: @dataset.name
    fill_in "Repository", with: @dataset.repository
    fill_in "Startdate", with: @dataset.startdate
    click_on "Update Dataset"

    assert_text "Dataset was successfully updated"
    click_on "Back"
  end

  test "should destroy Dataset" do
    visit dataset_url(@dataset)
    click_on "Destroy this dataset", match: :first

    assert_text "Dataset was successfully destroyed"
  end
end
