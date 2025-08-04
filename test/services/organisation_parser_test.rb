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
    puts "1st: #{r_a}"
    assert r_a[0] == "" and r_a[1] == "words in this string"

    puts "2nd: #{r_b}"
    assert r_b[0] == "words" and r_b[1] == " in this string"
  end
end
