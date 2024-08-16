require 'csv'

# create usage method
def check_usage
  unless ARGV.length == 1
    puts "Usage: data_parse.rb file_name.csv"
    exit
  end
end

def upload_data(csv_file)
    puts "***************************************************"
    puts csv_file
    puts "***************************************************"
    
    data_rows = CSV.read(csv_file)
    data_rows.each do |pub_row|
      if pub_row[4] != 'do_description' and pub_row[11] != nil
        puts "pub_id: " + pub_row[6] 
        puts "art_id: " + pub_row[1] + " art_doi: "+ pub_row[2]
        puts "Description: " + String(pub_row[3])
        puts "ds_doi: " + String(pub_row[4]) + "ds_location: "+ pub_row[6]
        puts "ds_name: " + pub_row[7] + "ds_start: "+ pub_row[8]
        puts "ds_type: " + pub_row[9] + "ds_repo: "+ pub_row[10]
        #ds_id = pub_row[6]pub_row[2]
        #art_id = pub_row[1]
        #art_doi = pub_row[2]
        #if @dor == nil
        #  @dor = Dataset.new()
        #  @dor.dataset_description = pub_row[4]
        #  @dor.dataset_doi = pub_row[5] 
        #  @dor.dataset_location = pub_row[6]
        #  @dor.dataset_name = pub_row[9]
        #  @dor.dataset_startdate = pub_row[10]
        #  @dor.ds_type = pub_row[11]
        #  @dor.repository = pub_row[12]
        #  @dor.save()
        #  # add article_dataset_link
        #  @art_ds_link = ArticleDataset.new()
        #  @art_ds_link.doi = art_doi 
        #  @art_ds_link.article_id = art_id
        #  @art_ds_link.dataset_id = @dor.id
        #  puts @art_ds_link.inspect()
        #end
      end
    end
end


if $0 == __FILE__
  check_usage
  #try five times before giving up
  try_n = 0
  data_file = ARGV[0]
  upload_data(data_file)
end
