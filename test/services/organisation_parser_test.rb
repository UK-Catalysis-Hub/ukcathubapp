require "test_helper"

class OrganisatioParserTest < ActiveSupport::TestCase
  setup do
    @article = articles(:one)
    @theme = themes(:one)
    @doi_existing = @article.doi
    @doi_uppercase = @doi_existing.upcase
    @doi_spaces = " " + @doi_existing + " "
    @doi_spc_n_uc =  " " + @doi_existing + " "
    # the firs doi has a xiv string in doi,
    # the second does not have pub_year
    @preprint_dois = ["10.1101/2025.07.05.663138",
                      "10.26434/chemrxiv-2024-cpjsk"
                      ]
    @ok_doi = "10.1021/acsmaterialslett.1c00766"
    @theme_list = [@theme.id]
    @org_p = OrganisationParser.new()
    @org_p.refresh_lists()
  end
  
  test "Test if an organisation is hosted by other" do
    inst_1 = "UK Catalysis Hub"
    inst_2 = "Research Complex at Harwell"
    assert @org_p.is_hosted(inst_1,inst_2)
    assert !(@org_p.is_hosted(inst_2,inst_1))
  end

  test "Test if hosting paths can be retrieved" do
    list = ["UK Catalysis Hub","Research Complex at Harwell","Rutherford Appleton Laboratory"]
    hosted_paths = [["UK Catalysis Hub", "Research Complex at Harwell"],
                    ["Research Complex at Harwell", "Rutherford Appleton Laboratory"],
                    ["UK Catalysis Hub", "Research Complex at Harwell", "Rutherford Appleton Laboratory"]]
    assert @org_p.is_hosted(list[0],list[1])
    assert @org_p.is_hosted(list[1],list[2])
    assert @org_p.get_host_paths(list) == hosted_paths
  end

  test "Test getting the longest path in the paths list" do
    hosted_paths = [["UK Catalysis Hub", "Research Complex at Harwell"],
                    ["Research Complex at Harwell", "Rutherford Appleton Laboratory"],
                    ["UK Catalysis Hub", "Research Complex at Harwell", "Rutherford Appleton Laboratory"]]
    assert @org_p.get_longest_path(hosted_paths) == hosted_paths[2]
  end

  test "Test checking if list has a value from list" do
    a_string = "words in this string"
    a_list = ['word', 'these', 'list']
    b_list = ['words', 'these', 'list']
    r_a = @org_p.check_list(a_string, a_list)
    r_b = @org_p.check_list(a_string, b_list)
    assert r_a[0] == "" and r_a[1] == "words in this string"
    assert r_b[0] == "words" and r_b[1] == " in this string"
  end

  test "Test checking if the string has a synonym" do
    a_string = "Oxford, UK"
    b_string = "Oxford, UL"
    ctry_sn = @org_p.get_country_synonyms
    r_a = @org_p.str_has_synonym(a_string, @org_p.get_country_synonyms)
    assert r_a[0] == "United Kingdom" and r_a[1] == "Oxford,"
    r_b = @org_p.str_has_synonym(b_string, @org_p.get_country_synonyms)
    assert r_b[0] == "" and r_b[1] == "Oxford, UL"
  end

  test "Test removing extra punctuation in string" do
    a_string = "Oxford , "
    assert @org_p.remove_extra_commas(a_string) == "Oxford"
    b_string = " , , ; ; Hello , world , ; "
    assert @org_p.remove_extra_commas(b_string) == "Hello, world,"
  end

  test "Test getting institutions in string" do
    a_dir_str = "UK Catalysis Hub, Research Complex at Harwell,\
                 Rutherford Appleton Laboratory, Harwell, UK"
    organisations_list = @org_p.get_organisations +
      ["UK Catalysis Hub",
       "Research Complex at Harwell",
       "Rutherford Appleton Laboratory"]
    a_res = @org_p.get_institutions_in_str(a_dir_str,
                                           @org_p.get_institution_synonyms,
                                           organisations_list)
    assert [["Rutherford Appleton Laboratory",
             "Research Complex at Harwell",
             "UK Catalysis Hub"], "Harwell, UK"] == a_res
    organisations_list += ["STFC"]
    b_dir_str = "UK Catalysis Hub, Research Complex at Harwell,\
                 Rutherford Appleton Laboratory, STFC, Harwell, OX11 1XX, UK"
    b_res = @org_p.get_institutions_in_str(b_dir_str,
                                           @org_p.get_institution_synonyms,
                                           organisations_list)
    # test fourth level nesting
    assert [["Science and Technology Facilities Council",
             "Rutherford Appleton Laboratory",
             "Research Complex at Harwell",
             "UK Catalysis Hub"], "Harwell, OX11 1XX, UK"] == b_res
  end

  test "Checking for country exceptions" do
    a_dir_str = "UK Catalysis Hub, Research Complex at Harwell, OX11 1XX, UK"
    assert  @org_p.has_country_exception(a_dir_str)
    b_dir_str = "Research Complex at Harwell, OX11 1XX, United Kingdom"
    assert  !@org_p.has_country_exception(b_dir_str)
  end
  
  test "getting country out of string" do
    a_dir_str = "UK Catalysis Hub, Research Complex at Harwell, OX11 1XX, UK"
    expected = ["United Kingdom",
                "UK Catalysis Hub, Research Complex at Harwell, OX11 1XX,"]
    assert @org_p.parse_countries2(a_dir_str) == expected
    b_dir_str = "UK Catalysis Hub, Research Complex at Harwell, OX11 1XX, US"
    expected_b = ["United States of America",
                  "UK Catalysis Hub, Research Complex at Harwell, OX11 1XX,"]
    assert @org_p.parse_countries2(b_dir_str)  == expected_b
  end
end
