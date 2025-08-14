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
    assert_equal "", r_a[0]
    assert_equal "words in this string", r_a[1]
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
    assert_equal ["Rutherford Appleton Laboratory",
            "Research Complex at Harwell",
            "UK Catalysis Hub", "Harwell, UK"], a_res
    organisations_list += ["STFC"]
    b_dir_str = "UK Catalysis Hub, Research Complex at Harwell,\
                 Rutherford Appleton Laboratory, STFC, Harwell, OX11 1XX, UK"
    b_res = @org_p.get_institutions_in_str(b_dir_str,
                                           @org_p.get_institution_synonyms,
                                           organisations_list)
    # test fourth level nesting
    assert ["Science and Technology Facilities Council",
            "Rutherford Appleton Laboratory",
            "Research Complex at Harwell",
            "UK Catalysis Hub", "Harwell, OX11 1XX, UK"] == b_res
    # test no inst in str:
    c_dir_str = "School of Chemistry"
    c_res = @org_p.get_institutions_in_str(c_dir_str,
                                           @org_p.get_institution_synonyms,
                                           organisations_list)
    assert_equal ["", "School of Chemistry"],  c_res
  end

  test "Checking for country exceptions" do
    a_dir_str = "UK Catalysis Hub, Research Complex at Harwell, OX11 1XX, UK"
    assert  @org_p.has_country_exception(a_dir_str)
    b_dir_str = "Research Complex at Harwell, OX11 1XX, United Kingdom"
    assert  !@org_p.has_country_exception(b_dir_str)
  end
  
  test "parsing country in string" do
    a_dir_str = "UK Catalysis Hub, Research Complex at Harwell, OX11 1XX, UK"
    expected = ["United Kingdom",
                "UK Catalysis Hub, Research Complex at Harwell, OX11 1XX,"]
    assert @org_p.parse_countries(a_dir_str) == expected
    b_dir_str = "UK Catalysis Hub, Research Complex at Harwell, OX11 1XX, US"
    expected_b = ["United States of America",
                  "UK Catalysis Hub, Research Complex at Harwell, OX11 1XX,"]
    assert @org_p.parse_countries(b_dir_str)  == expected_b
  end

  test "parsing organisation in string" do
    a_dir_str = "UK Catalysis Hub, Research Complex at Harwell, OX11 1XX, UK"
    result_a = @org_p.parse_institutions(a_dir_str)
    expected_a = ["UK Catalysis Hub", "Research Complex at Harwell, OX11 1XX, UK"]
    assert result_a == expected_a
    b_dir_str = "UK Catalysis Hub, Research Complex at Harwell, Rutherford Appleton Laboratory, OX11 1XX, UK"
    result_b = @org_p.parse_institutions(b_dir_str) 
    expected = ["UK Catalysis Hub", "Research Complex at Harwell, Rutherford Appleton Laboratory, OX11 1XX, UK"]
    assert result_b == expected
    c_dir_str = "UK Catalysis Hub, RCaH, RAL, OX11 1XX, UK"
    result_c = @org_p.parse_institutions(c_dir_str)
    assert result_c == expected
    d_dir_str = "UK Catalysis Hub, RCaH, STFC OX11 1XX, UK"
    result_d = @org_p.parse_institutions(d_dir_str)
    expected_d = ["UK Catalysis Hub", "Research Complex at Harwell, Science and Technology Facilities Council OX11 1XX, UK"]
    assert result_d == expected_d
    e_dir_str = "UK Catalysis Hub, Harwell, OX11 1XX, UK"
    expected_e = ["UK Catalysis Hub", "Harwell, OX11 1XX, UK"]
    result_e = @org_p.parse_institutions(e_dir_str)
    assert result_e == expected_e
    f_dir_str = "UK Catalysis Hub"
    expected_f = ["UK Catalysis Hub", ""]
    result_f = @org_p.parse_institutions(f_dir_str)
    assert result_f == expected_f
  end

  test "parse organisational units" do
    a_dir_str = "Cardiff Catalysis Institute, School of Chemistry, Cardiff University, Cardiff, Wales, UK"
    inst_str, splitting_this = @org_p.parse_institutions(a_dir_str)
    assert_equal inst_str, "Cardiff University"
    assert "Cardiff Catalysis Institute, School of Chemistry Cardiff, Wales, UK" == splitting_this
    expected = [[["school", "School of Chemistry"],
                 ["work_group", "Cardiff Catalysis Institute"]],
                "Cardiff, Wales, UK"]
    assert_equal expected, @org_p.parse_org_units(splitting_this.clone)
  end

  test "remove returns from string" do
    test_string = "This\u202fis a string \n with \r  different returns,   and\u2005extra   spaces"
    expected = "This is a string with different returns, and extra spaces"
    a_result = @org_p.clean_address_string(test_string)
    assert_equal expected, a_result
    edge_case = " \n\r\u2005Start  clean"
    expected = "Start clean"
    a_result = @org_p.clean_address_string(edge_case)
    assert_equal expected, a_result
    edge_case = "\t\rTom &amp; Jerry"
    expected = "Tom & Jerry"
    a_result = @org_p.clean_address_string(edge_case)
    assert_equal expected, a_result
    test_string = "O''Reilly lives &amp; works at&nbsp;123\u2005Main\rSt.\n"
    expected = "O'Reilly lives & works at 123 Main St."
    assert_equal expected, @org_p.clean_address_string(test_string)
  end

  test "testing single line affiliations" do
    first_string = 'School of Chemistry, Cardiff University, Main Building, Park Place, Cardiff CF10 3AT, United Kingdom'
    expected = {:institution=>"Cardiff University",
                :school=>"School of Chemistry",
                :department=>"", :faculty=>"",
                :work_group=>"", :country=>"United Kingdom",
                :address=>"Main Building, Park Place, Cardiff CF10 3AT"}
    second_string = 'UK Catalysis Hub, Research Complex at Harwell, Rutherford Appleton Laboratory, Didcot, Oxfordshire OX11 0FA, United Kingdom'
    
    assert_equal expected, @org_p.split_single(first_string)
    expected = {:institution=>"UK Catalysis Hub",
                :school=>"", :department=>"", :faculty=>"",
                :work_group=>"", :country=>"United Kingdom", 
                :address=>"Research Complex at Harwell, Rutherford Appleton Laboratory, Didcot, Oxfordshire OX11 0FA"}
    assert_equal expected, @org_p.split_single(second_string)
    third_str = "School of Chemistry"
    expected = {:institution=>"", :school=>"School of Chemistry",
                :department=>"", :faculty=>"", :work_group=>"",
                :country=>"", :address=>""}
    assert_equal expected, @org_p.split_single(third_str)
  end

  test "map and parse singles affi in line" do
    first_string = 'School of Chemistry, Cardiff University, Main Building, Park Place, Cardiff CF10 3AT, United Kingdom'
    second_string = 'UK Catalysis Hub, Research Complex at Harwell, STFC Rutherford Appleton Laboratory, Didcot, Oxfordshire OX11 0FA, United Kingdom'
    first_expected = [
        {:institution=>"Cardiff University", :school=>"School of Chemistry",
         :department=>"", :faculty=>"", :work_group=>"",
         :country=>"United Kingdom",
         :address=>"Main Building, Park Place, Cardiff CF10 3AT"}, [1]]
    second_expected = [
        {:institution=>"UK Catalysis Hub", :school=>"", :department=>"",
         :faculty=>"", :work_group=>"", :country=>"United Kingdom",
         :address=>"Research Complex at Harwell, Rutherford Appleton Laboratory, Science and Technology Facilities Council, Didcot, Oxfordshire OX11 0FA"}, [2]]
    first_result = @org_p.parse_and_map_single([1, first_string])
    second_result = @org_p.parse_and_map_single([2, second_string])
    assert_equal first_expected, first_result
    assert_equal second_expected, second_result
  end

  test "parse multiline" do
    affiliation_lines = [
         [1, 'School of Chemistry'],[2, 'Cardiff University'],
         [3, 'Main Building, Park Place, Cardiff CF10 3AT, United Kingdom']]
    first_expected = [[
        {:institution=>"Cardiff University", :school=>"School of Chemistry",
         :department=>"", :faculty=>"", :work_group=>"",
         :country=>"United Kingdom",
         :address=>"Main Building, Park Place, Cardiff CF10 3AT"}, [1,2,3]]]
    result_first = @org_p.parse_and_map_multiline(affiliation_lines)
    assert_equal first_expected, result_first
    second_lines = [
         [1,'UK Catalysis Hub'], [2,'Research Complex at Harwell'],
         [3, 'Rutherford Appleton Laboratory'],
         [4,'Didcot, Oxfordshire OX11 0FA, United Kingdom']]
    second_expected = [[
        {:institution=>"UK Catalysis Hub", :school=>"", :department=>"",
         :faculty=>"", :work_group=>"", :country=>"United Kingdom", 
         :address=>"Research Complex at Harwell, Rutherford Appleton Laboratory, Didcot, Oxfordshire OX11 0FA"}, [1, 2, 3, 4]]]
    second_result = @org_p.parse_and_map_multiline(second_lines)
    assert_equal second_expected, second_result
    third_lines = [
         [15, 'School of Chemistry, Cardiff University, Main Building, Park Place, Cardiff CF10 3AT, United Kingdom'],
         [25, 'UK Catalysis Hub, Research Complex at Harwell, STFC Rutherford Appleton Laboratory, Didcot, Oxfordshire OX11 0FA, United Kingdom']]
    #puts @org_p.parse_and_map_multiline(third_lines).inspect
  end

  test "testing for one liners" do
    affiliation_lines = [
         [1, 'School of Chemistry'],[2, 'Cardiff University'],
         [3, 'Main Building, Park Place, Cardiff CF10 3AT, United Kingdom']]
    affiliation_lines.each do |cr_affi_id, affi_ln|
      assert_equal false, @org_p.is_one_liner(affi_ln), "This should not be a one liner #{affi_ln}"
    end
    first_string = 'School of Chemistry, Cardiff University, Main Building, Park Place, Cardiff CF10 3AT, United Kingdom'
    second_string = 'UK Catalysis Hub, Research Complex at Harwell, STFC Rutherford Appleton Laboratory, Didcot, Oxfordshire OX11 0FA, United Kingdom'
    assert_equal true, @org_p.is_one_liner(first_string), "This should be a one liner #{first_string}"
  end

  test "Unhandled and Messy cases" do
    puts "fail parsing more than one inst in string, not seen yet"
    a_dir_str = "UK Catalysis Hub, Cardiff University"
    puts @org_p.parse_institutions(a_dir_str).inspect
    puts @org_p.split_single(a_dir_str).inspect
  end
  

end
