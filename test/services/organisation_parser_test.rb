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

end
