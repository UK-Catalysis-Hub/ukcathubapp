require 'serrano'
require 'json'
require 'sqlite3'
require 'fuzzystringmatch'


class Author
  attr_accessor :id, :last_name, :given_name, :orcid, :articles
  # class attributes
  @id = nil
  @last_name = ""
  @given_name = ""
  @orcid = nil
  @articles =0
end

# check two strings similarity
def similar(a, b)
  jarow = FuzzyStringMatch::JaroWinkler.create( :pure )
  return jarow.getDistance( a, b)
end

# create usage method
def check_usage
  unless ARGV.length == 1
    puts "Usage: add_to_db.rb doi_id"
    exit
  end
end

# get bib data from crossref
def getBibData(doi_text)
  puts doi_text
  begin
    art_bib = JSON.parse(Serrano.content_negotiation(ids: doi_text, format: "citeproc-json"))
    puts art_bib
    return art_bib
  rescue
    puts 'something happened, rescue'
    return nil
  end
end

exclude_columns = ['author','assertion','indexed', 'funder','content-domain',
  'created','update-policy','source','is-referenced-by-count','prefix',
  'member','reference','original-title','language','deposited','score',
  'subtitle', 'short-title', 'issued','alternative-id','relation','ISSN',
  'container-title-short']

if $0 == __FILE__
  check_usage
  #try five times before giving up
  try_n = 0
  while try_n < 5 do
    doi_text = ARGV[0]
    article_data = getBibData(doi_text)
    if article_data != nil
      break
    else
      puts ("****************************************************")
      puts ("retry" + try_n + article_data)
      try_n += 1
    end
  end
  data_keys = article_data.keys()
  puts data_keys
  article_columns = ["Num"]
  for key in data_keys do
    if not article_columns.include?(key) and not exclude_columns.include?(key)
      article_columns.append(key)
    end
  end
  puts("******************ARTICLE COLUMNS*******************")
  puts("ARTICLE: " + doi_text + "COLUMNS: " + article_columns.to_s)
  # convert to article object and save
  begin
    db = db = SQLite3::Database.open "../db/development.sqlite3"
    puts db.get_first_value 'SELECT SQLITE_VERSION()'
    stm = db.prepare "SELECT * FROM Articles WHERE Articles.doi = '" + doi_text + "'"
    rs = stm.execute
    rs.each do |row|
      puts "EXISTING RECORD:"
      puts row.join "\s"
    end
    # for each author: search if already in the DB, first by orcid, then by name
    # if exact match, just get the id
    # if close match, ask
    #   if map to existing: then add an alias (may need alias affiliation)
    #   if new: insert into db as new author
    puts("******************ARTICLE AUTHORS("+
      article_data['author'].length().to_s()+")*******************")
    puts(article_data['author'])
    puts("********************************************************************")
    article_data['author'].each do |art_author|
      found_orcid = false
      found_exact = false
      found_similar = false
      puts "CHECKING:" + art_author.to_s
      new_author = Author.new
      if art_author.keys.include?('ORCID')
        new_author.orcid = art_author['ORCID']
        puts "ORCID: " + new_author.orcid
      end
      if art_author.keys.include?('family')
        new_author.last_name = art_author['family']
        puts "lastname: " + new_author.last_name
      end
      if art_author.keys.include?('given')
        new_author.given_name = art_author['given']
        puts "name: " + new_author.given_name
      end
      if new_author.orcid
        stm = db.prepare "SELECT * FROM Authors WHERE Authors.orcid = '" + new_author.orcid + "'"
        rs = stm.execute
        rs.each do |row|
          puts "***FOUND BY ORCID: " + row[1]
          new_author.id = row[0]
          found_orcid = true
        end
      end
      if new_author.id == nil and found_orcid == false
        stm = db.prepare "SELECT * FROM Authors WHERE Authors.last_name = '" + new_author.last_name + \
                "'AND Authors.given_name = '" + new_author.given_name + "'"
        rs = stm.execute
        rs.each do |row|
          puts "***FOUND EXACT MATCH: " + row[1]
          puts row
          new_author.id = row[0]
          found_exact = true
        end
      end
      if new_author.id == nil and found_exact == false
        stm = db.prepare "SELECT * FROM Authors WHERE Authors.last_name like '%" + new_author.last_name + "%'"
        rs = stm.execute
        rs.each do |row|
          found_fn = row[2] + row[3]
          new_auth =  new_author.last_name + new_author.given_name
          name_similarity = similar(new_auth, found_fn)
          if name_similarity > 0.7
            puts "***MATCH FOUND: " + found_fn + " " + name_similarity.to_s
            found_exact = true
          end
        end
      end
    end
  rescue SQLite3::Exception => e
    puts "Exception occurred"
    puts e
  ensure
    stm.close if stm
    db.close if db
  end
end
