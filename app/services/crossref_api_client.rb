# app/services/crossref_api_client.rb
include Serrano

class CrossrefApiClient
  def self.getCRData(doi_text)
    begin
        puts "********************************"
        puts "trying to get data from crossref"
        puts "********************************"
        art_bib = JSON.parse(Serrano.content_negotiation(ids: doi_text, format: "citeproc-json"))
        return art_bib
    rescue
        puts "*********************************"
        puts "failed getting data from crossref"
        puts "*********************************"
        return nil
    end
  end
end
