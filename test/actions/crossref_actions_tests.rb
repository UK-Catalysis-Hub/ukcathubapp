# Adhoc tester, devise broke tests, need to fix it eventually
# quick and dirty testing from rails console

require 'set'

$affi_sep = CrossrefPublication::AffiliationLists.new

def run_my_tests
  # disable sql logger for clearer output
  disable_sql_logger
  # keyword splitter tests
  split_single_test ? print('.') : print('E')
  split_complex_test ? print('.') : print('E')
  split_complex_two_inst_test ? print('.') : print('E')
  all_elements_in_same_affi_test ? print('.') : print('E')
  all_elements_in_one_affi_test ? print('.') : print('E')
  all_elements_in_one_affi_fail_test ? print('.') : print('E')
  workgroup_doesnt_break_test ? print('.') : print('E')

  # one by one CR affiliation handler tests
  obo_multiline_affis_test ? print('.') : print('E')
  test_obo_liners_ok ? print('.') : print('E')
  test_obo_liners_ok(2) ? print('.') : print('E')
  test_obo_liners_ok(3) ? print('.') : print('E')
  test_obo_liners_ok(4) ? print('.') : print('E')
  test_obo_liners_ok(5) ? print('.') : print('E')

  # test creating db_affis
  build_two_db_affis_from_multi_test ? print('.') : print('E')
  build_one_db_affi_from_multi_test ? print('.') : print('E')
  build_one_db_affi_from_single_liners_test ? print('.') : print('E')

  # restore sql logger after running tests
  enable_sql_logger
  return ""
end

$sql_logger = ActiveRecord::Base.logger

def disable_sql_logger
  # disable sql logger for clearer output
  ActiveRecord::Base.logger = nil
end

def enable_sql_logger
  # disable sql logger for clearer output
  ActiveRecord::Base.logger = $sql_logger
end


# Tests for split_by_keywords3
def split_single_test
  # test that the splitter will not break the string and will return hash with
  # element identified
  affi_string = "Aarhus University"
  return_hash = $affi_sep.split_by_keywords3(affi_string)
  if return_hash == {"institution"=>"Aarhus University"} then
    return true
  else
    return false
  end
end

def split_complex_test
  # test that the spliter splits string in all component elemets correctly
  affi_string = "School of ChemistryUniversity of Bristol Cantock's Close Bristol BS81TS UK"
  return_hash = $affi_sep.split_by_keywords3(affi_string)
  if return_hash.count == 4 then
    return true
  else
    return false
  end
end

def split_complex_two_inst_test
  # test that the spliter splits string in all component elemets correctly when
  # affi string contains two affiliations
  affi_string = "UK Catalysis Hub, Research Complex at Harwell, Rutherford Appleton Laboratory, Harwell, Oxon OX11 0FA, United Kingdom"
  $affi_sep.split_by_keywords3(affi_string)
  return_hash = $affi_sep.split_by_keywords3(affi_string)
  if return_hash.count == 4 then
    return true
  else
    return false
  end
end

def all_elements_in_same_affi_test
  # test that elements in return hash match some affiliation in DB
  affi_string = "UK Catalysis Hub, Research Complex at Harwell, Rutherford Appleton Laboratory, Harwell, Oxon OX11 0FA, United Kingdom"
  temp_lines = $affi_sep.split_by_keywords3(affi_string)
  if $affi_sep.same_affi(temp_lines.values)
    return true
  else
    return false
  end
end

def all_elements_in_one_affi_test
  # test that elements in return hash match a single affiliation in DB
  affi_string = "UK Catalysis Hub, Research Complex at Harwell, Rutherford Appleton Laboratory, Harwell, Oxon OX11 0FA, United Kingdom"
  temp_lines = $affi_sep.split_by_keywords3(affi_string)
  if $affi_sep.one_affi(temp_lines)
    return true
  else
    return false
  end
end

def all_elements_in_one_affi_fail_test
  # test that test fails if elements in return hash do not match a single
  # affiliation in DB
  affi_string = "UK Catalysis Hub, Research Complex at Harwell, Rutherford Appleton Laboratory, Harwell, Oxon OX11 0FA, Ireland"
  temp_lines = $affi_sep.split_by_keywords3(affi_string)
  if $affi_sep.one_affi(temp_lines)
    return false
  else
    return true
  end
end

def workgroup_doesnt_break_test
  affi_string = "Centre for Computational Chemistry"
  temp_lines = $affi_sep.split_by_keywords3(affi_string)
  if temp_lines == {"work_group"=>"Centre for Computational Chemistry"} then
    return true
  else
    return false
  end
end

#tests of the one by one splitter
def obo_multiline_affis_test
  # test that splitter returns a single affiliation when it is made of multiple lines
  affi_lines = CrAffiliation.where("article_author_id=54")
  temp_lines = $affi_sep.one_by_one_affi(affi_lines)
  if temp_lines.count == 1 then
    return true
  else
    return false
  end
end

def test_obo_liners_ok(num_lines=1)
  # check if there are issues when splitting CR affiliations consisting of a
  # single line
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id) = '+ num_lines.to_s ).count
  problems = []
  multi.keys.each do |an_auth_id|
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    if return_hash[0] == nil then
      problems.append(an_auth_id)
    elsif return_hash.count > num_lines then
      problems.append(an_auth_id)
    end
  end
  if problems.count>0 then
    return false
  else
    return true
  end
  print"\nIssues: " + problems.to_s
end



def all_records_test
  # run splitter on all records
  ArticleAuthor.all.each do |an_auth|
    if an_auth.cr_affiliations.count > 0
      puts "\n****Author: " + an_auth.id.to_s
      affi_lines = CrAffiliation.where("article_author_id="+ an_auth.id.to_s)
      $affi_sep.one_by_one_affi(affi_lines)
    end
  end
end

# test build affi stubs for all records
def all_records_build_test
  disable_sql_logger
  # test that splitter and builder work for all records
  db_affis_created = []
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id)>0').count
  multi.keys.each {|an_auth_id|
    affi_lines = CrAffiliation.where("article_author_id = " + an_auth_id.to_s)
    temp_lines = $affi_sep.one_by_one_affi(affi_lines)
    db_affis_created.append($affi_sep.build_affi_stubs(temp_lines, an_auth_id))
  }
  print db_affis_created
  disable_sql_logger
end

def test_07
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id)=1').count
  multi.keys.each do |an_auth_id|
    puts "\n****Author: " + an_auth_id.to_s + " Lines: " + multi[an_auth_id].to_s
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    print "\ninput lines: "
    print_lines(affi_lines)
    print "\nreturn hash:\n\t" + return_hash.to_s
  end
end

def test_08
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id)=2').count
  multi.keys.each do |an_auth_id|
    puts "\n****Author: " + an_auth_id.to_s + " Lines: " + multi[an_auth_id].to_s
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    print "\nreturn hash " +return_hash.to_s
  end
end

def test_09
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id)=3').count
  multi.keys.each do |an_auth_id|
    puts "\n****Author: " + an_auth_id.to_s + " Lines: " + multi[an_auth_id].to_s
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    print "\nreturn hash " +return_hash.to_s
  end
end

def test_10
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id)=4').count
  multi.keys.each do |an_auth_id|
    puts "\n****Author: " + an_auth_id.to_s + " Lines: " + multi[an_auth_id].to_s
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    print "\nreturn hash " +return_hash.to_s
  end
end

def test_11
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id)>4').count
  multi.keys.each do |an_auth_id|
    puts "\n****Author: " + an_auth_id.to_s + " Lines: " + multi[an_auth_id].to_s
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    print "\ninput lines: "
    print_lines(affi_lines)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    print "\nreturn hash " +return_hash.to_s
  end
end

def test_one_ok()
  # test one liners: passing with no changes
  one_liners_ok = [16,423] #, 89, 90, 183,  797, 2309, 466, 800, 2310, 583, 627, 638, 2308, 573, 574, 578, 516, 519, 468, 472, 473]
  one_liners_ok.each do |an_auth_id|
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    puts "\n****Author: " + an_auth_id.to_s + " Lines: 1"
    print "\ninput lines: "
    print_lines(affi_lines)
    print "\nreturn hash " +return_hash.to_s
  end
end

def test_one_prob()
  # test one liners: not working
  one_liners_ok = [384, 385]
  one_liners_ok.each do |an_auth_id|
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = one_by_one_affi(affi_lines)
    puts "\n****Author: " + an_auth_id.to_s + " Lines: 1"
    print "\ninput lines: "
    print_lines(affi_lines)
    print "\nreturn hash " +return_hash.to_s
  end
end

def test_probs_one()
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id)=1').count
  problems = []
  multi.keys.each do |an_auth_id|
    puts "\n****Author: " + an_auth_id.to_s + " Lines: " + multi[an_auth_id].to_s
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    print "\ninput lines: "
    print_lines(affi_lines)
    print "\nreturn hash:\n\t" + return_hash.to_s
    if return_hash[0] == nil then
      problems.append(an_auth_id)
    elsif return_hash.count > 1 then
      problems.append(an_auth_id)
    end
  end
  print"\nIssues: " + problems.to_s
end

def test_probs_two()
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id)=2').count
  problems = []
  multi.keys.each do |an_auth_id|
    puts "\n****Author: " + an_auth_id.to_s + " Lines: " + multi[an_auth_id].to_s
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    print "\ninput lines: "
    print_lines(affi_lines)
    print "\nreturn hash:\n\t" + return_hash.to_s
    return_hash.each{|k, v|
      if v == nil then
        problems.append(an_auth_id)
      end
    }
    if return_hash.count > 2 then
      problems.append(an_auth_id)
    end
  end
  print"\nIssues: " + problems.to_s
end

def test_three_prob()
  # test three liners: not working
  one_liners_ok = [189]
  one_liners_ok.each do |an_auth_id|
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = one_by_one_affi(affi_lines)
    puts "\n****Author: " + an_auth_id.to_s + " Lines: 1"
    print "\ninput lines: "
    print_lines(affi_lines)
    print "\nreturn hash " +return_hash.to_s
  end
end

def test_probs_three()
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id)=3').count
  problems = []
  multi.keys.each do |an_auth_id|
    puts "\n****Author: " + an_auth_id.to_s + " Lines: " + multi[an_auth_id].to_s
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    print "\ninput lines: "
    print_lines(affi_lines)
    print "\nreturn hash:\n\t" + return_hash.to_s
    return_hash.each{|k, v|
      if v == nil then
        problems.append(an_auth_id)
      end
    }
    if return_hash.count > 3 then
      problems.append(an_auth_id)
    end
  end
  print"\nIssues: " + problems.to_s
end

def test_probs_four()
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id)=4').count
  problems = []
  multi.keys.each do |an_auth_id|
    puts "\n****Author: " + an_auth_id.to_s + " Lines: " + multi[an_auth_id].to_s
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    print "\ninput lines: "
    print_lines(affi_lines)
    print "\nreturn hash:\n\t" + return_hash.to_s
    return_hash.each{|k, v|
      if v == nil then
        problems.append(an_auth_id)
      end
    }
    if return_hash.count > 4 then
      problems.append(an_auth_id)
    end
  end
  print"\nIssues: " + problems.to_s
end

def test_probs_five()
  disable_sql_logger
  multi = ArticleAuthor.joins(:cr_affiliations).group('Article_authors.id').having('count(article_author_id)=5').count
  problems = []
  multi.keys.each do |an_auth_id|
    puts "\n****Author: " + an_auth_id.to_s + " Lines: " + multi[an_auth_id].to_s
    affi_lines = CrAffiliation.where("article_author_id="+ an_auth_id.to_s)
    return_hash = $affi_sep.one_by_one_affi(affi_lines)
    print "\ninput lines: "
    print_lines(affi_lines)
    print "\nreturn hash:\n\t" + return_hash.to_s
    return_hash.each{|k, v|
      if v == nil then
        problems.append(an_auth_id)
      end
    }
    if return_hash.count > 5 then
      problems.append(an_auth_id)
    end
  end
  print"\nIssues: " + problems.to_s
  enable_sql_logger
end

def test_lehigh
  affi_string = "Department of Materials Science and Engineering Lehigh University, 5 East Packer Avenue, Bethlehem, PA 18015, USA"
  $affi_sep.split_by_keywords3(affi_string)
end

def test_belfast
  affi_string = "School of Chemistry and Chemical Engineering; Queen's University Belfast; Belfast BT9 5AG N. Ireland UK"
  split_by_keywords3(affi_string)
end

def print_lines(affi_lines)
   affi_lines.each do |cr_affi|
     print "\n\t" + cr_affi.name
   end
end


# test create affi when the affiliation is in multiple lines
def build_two_db_affis_from_multi_test
  # test that splitter returns two affilition when they are
  # made of multiple lines
  auth_ids = [927, 941]
  db_affis_created = []
  auth_ids.each{|auth_id|
    affi_lines = CrAffiliation.where("article_author_id = " + auth_id.to_s)
    temp_lines = $affi_sep.one_by_one_affi(affi_lines)
    db_affis_created.append($affi_sep.build_affi_stubs(temp_lines, auth_id))
  }
  if db_affis_created.count == 2 and db_affis_created[0] == db_affis_created[1]\
     and db_affis_created[0] == 2 then
    return true
  else
    return false
  end
end

# test create affi when the affiliation is in multiple lines
def build_one_db_affi_from_multi_test
  # test that splitter returns one affilition when they are
  # made of multiple lines
  auth_ids = [2266, 2323]
  db_affis_created = []
  auth_ids.each{|auth_id|
    affi_lines = CrAffiliation.where("article_author_id = " + auth_id.to_s)
    temp_lines = $affi_sep.one_by_one_affi(affi_lines)
    db_affis_created.append($affi_sep.build_affi_stubs(temp_lines, auth_id))
  }
  if db_affis_created.count == 2 and db_affis_created[0] == db_affis_created[1]\
     and db_affis_created[0] == 1 then
    return true
  else
    return false
  end
end

# test create affi when the affiliation is in multiple lines
def build_one_db_affi_from_single_liners_test
  # test that splitter returns one affilition when they are
  # made of multiple lines
  auth_ids = [16, 89]
  db_affis_created = []
  auth_ids.each{|auth_id|
    affi_lines = CrAffiliation.where("article_author_id = " + auth_id.to_s)
    temp_lines = $affi_sep.one_by_one_affi(affi_lines)
    db_affis_created.append($affi_sep.build_affi_stubs(temp_lines, auth_id))
  }
  if db_affis_created.count == 2 and db_affis_created[0] == db_affis_created[1]\
     and db_affis_created[0] == 1 then
    return true
  else
    return false
  end
end


# analise the affi hashes and determine if they belong to a single or various
# affiliations. Last step before actually building the affiliations
def build_affi_stubs(temp_lines, auth_id = 0)
  print temp_lines
  affis_built = 0
  if temp_lines.count > 0 then
    affi_previous = nil
    previous = nil
    build_affis=[]
    temp_lines.each { |k,v|
      current = v # get the values of current affi
      if previous != nil then
        affi_current = get_affi(current)
        curr_inst = affi_current.institution.strip.downcase
        prev_inst = affi_previous.institution.strip.downcase
        affi_current.addresses[0].add_01
        curr_add = affi_current.addresses[0].add_01.strip.downcase
        prev_add = affi_previous.addresses[0].add_01.strip.downcase
        if curr_inst == prev_add then
	        print "\n"+ prev_inst + " is hosted by " + curr_inst
	        print "\n create single affi for " + prev_inst
          build_affis.append(previous.values + current.values)
  	      # skip current in next loop by making previous = current
	        current = previous
    	  elsif curr_add == prev_inst then
	        print "\n"+ curr_inst + " is hosted by " + prev_inst
          print "\n create single affi for " + curr_inst
	        build_affis.append(current.values + previous.values)
        else
          print "\n"+ curr_inst + " and " + prev_inst + "are independent"
          print "\n create an affi for each "
	        if build_affis[build_affis.count -1] == nil \
             or !build_affis[build_affis.count -1].include?(affi_previous.institution) then
            build_affis.append(previous.values)
          end
	        build_affis.append(current.values)
	    end
      end
    previous = current
    affi_previous = get_affi(previous)
    }
    if build_affis.count == 0 then
      # there was only one affiliation in hash, build it
      build_affis.append(previous.values)
    end
    print "\n BUILD THESE AFFIS: " + build_affis.to_s
    build_affis.each{|lines_list|
      affi_obj = $affi_sep.create_affi_obj(lines_list, auth_id)
      $affi_sep.print_affi(affi_obj)
      affis_built += 1
    }
  end
  # return the number of new db affis created
  return affis_built
end

# get the bets matching affilition for a given hash
# helper for build affi stubs
def get_affi(affi_hash)
  valid_keys = ["institution","work_group","department","faculty","country"]
  find_str = ""
  has_keys = []
  affi_hash.keys.each do |item_key|
    if affi_hash[item_key].to_s != "" and valid_keys.include?(item_key.to_s)
      find_str += item_key.to_s + " = '" + affi_hash[item_key].gsub("'","''") + "' and "
    end
  end
  # add country from ctry_syn
  if affi_hash.keys.include?("ctry_syn") and !affi_hash.keys.include?("country") then
    ctry_name = $affi_sep.get_country_from_synonym(affi_hash["ctry_syn"])
    find_str += "country = '" + ctry_name.gsub("'","''") + "' and "
  end
  if find_str != "" then
    find_str = find_str[..-5]
    found_affis = Affiliation.where(find_str)
    if found_affis.count > 0 then
      print found_affis.count
      if found_affis.count == 1 then
        return found_affis[0]
      else
        # Determine which is the closest match for the affi at hand
        candidate_scores = {}
        affi_index = 0
        relevant_keys = affi_hash.keys.to_set().intersection(valid_keys.to_set())
        exclude_keys = valid_keys.to_set() - affi_hash.keys.to_set()
        found_affis.each do |an_affi|
	  # check if affi matches only relevant and does not have other fields filled
          print "\nLOOKING FOR KEYS " + relevant_keys.to_s
          print "\nIGNORING KEYS:   " + exclude_keys.to_s
          likely_candidate = 0
          exclude_keys.each {|key|
            if an_affi.attributes[key].to_s == "" then
              likely_candidate  += 1
            end
          }
          candidate_scores[affi_index] = likely_candidate
          affi_index+=1
        end
        print "\nScores: " + candidate_scores.to_s
	candidate_scores = candidate_scores.sort_by{|k,v| v}.reverse()
	puts "\nHigh Score: " + candidate_scores[0][0].to_s
	high_score = candidate_scores[0][0]
        return found_affis[high_score]
      end
    end
  end
end


def test_overlaps
  indexes = {74=>[44, "institution"], 163=>[6, "country"], 52=>[20, "faculty"], 0=>[50, "workgroup"], 63=>[9, "department"]}
  kw_indexes = indexes
  kw_indexes = kw_indexes.sort.to_h
  previous = []
  remove = -1
  kw_indexes.each{|k,v|
    if previous == [] then
      previous=[k,k+v[0]]
    else
      current=[k,k+v[0]]
      print "\ncurrent = "+ current.to_s
      print "\nprevious = "+ previous.to_s
      # current inside previous
      if (previous[0]<current[0] and previous[1]>=current[1]) or \
         (previous[0]<=current[0] and previous[1]>current[1])
        print "\n" + kw_indexes[current[0]].to_s + " is inside " + kw_indexes[previous[0]].to_s
        print "\nRemove curr" + kw_indexes[current[0]].to_s
        remove = current[0]
        break
      # previous inside current
      elsif (previous[0]>current[0] and previous[1]<=current[1]) or \
         (previous[0]>=current[0] and previous[1]<current[1]) then
        print "\n" + kw_indexes[previous[0]].to_s + " is inside " + kw_indexes[current[0]].to_s
        print "\nRemove prev" + kw_indexes[previous[0]].to_s
        remove = previous[0]
        break
      end
      previous=current
    end
  }
  if remove > -1
    kw_indexes.delete(remove)
  end
  print kw_indexes
end

def test_overlaps2
  indexes = {74=>[44, "institution"], 163=>[6, "country"], 52=>[20, "faculty"], 0=>[50, "workgroup"], 63=>[9, "department"]}
  kw_indexes =  remove_overlaps(indexes)
  print kw_indexes
end

def remove_overlaps(kw_indexes)
  kw_indexes = kw_indexes.sort.to_h
  previous = []
  remove = -1
  kw_indexes.each{|k,v|
    if previous == [] then
      previous=[k,k+v[0]]
    else
      current=[k,k+v[0]]
      # current inside previous
      if (previous[0]<current[0] and previous[1]>=current[1]) or \
         (previous[0]<=current[0] and previous[1]>current[1])
        remove = current[0]
        break
      # previous inside current
      elsif (previous[0]>current[0] and previous[1]<=current[1]) or \
         (previous[0]>=current[0] and previous[1]<current[1]) then
        remove = previous[0]
        break
      end
      previous=current
    end
  }
  if remove > -1
    kw_indexes.delete(remove)
  end
  return kw_indexes
end



    # get a set of affi lines and determie how many belong to an affiliation
    # e.g. "Interdisciplinary Nanoscience Center (iNANO) and Department of Physics and Astronomy"
    #      "Aarhus University"
    #      "DK-8000 Aarhus C, Denmark"
    #      "Department of Chemistry and Interdisciplinary Nanoscience Center (iNANO)"
    def one_by_one_affi(affi_lines)
      # split the first line
      # add it to affi_lines if affi_lines empty
      # in next line try to see if the string belongs to same affiliation
      # after first line try adding to affi_items, if resulting in same affi, add, else start new affi_items
      affi_items = {}
      indx = 0
      other_lines = 1
      affi_items[indx] = nil
      temp_affi = nil
      affi_lines.each do |cr_affi|
        #print "\nElement: " + cr_affi.name.strip.gsub("'","''")
        # split element by keywords
        temp_split = split_by_keywords3(cr_affi.name.strip)#.gsub("'","''"))
        # when no fragment is recognised as a keyword?
        if temp_split == {} then
        #  print "\nElement: " + cr_affi.name.strip + " *** not recognised ***"
	       temp_split = {"line_"+other_lines.to_s => cr_affi.name.strip}
	        other_lines += 1
        #else
        #  print "\nSplit: " + temp_split.to_s
        end

        #temp_affi = temp_split
        #   - test if current affiliation is full (i.e. inst, dep, fcty, wg, cty.)
        #     or already contains the elements just returned
        #     - not complete then test if it fits with current affiliation
        #       - if an affi is element already filled then mark current affi as
        #         - complete and create a new affi.
        #           - mark as complete requires looking for matches and missing minimal parts in affiliations table: i.e. inst, ctry,
        #           - if inst and ctry blank, use the same as last one (i.e. inst and ctry from previous)

        # currently there is no affiliation
        add_another = false
        if affi_items[indx] == nil then
          # if all elements are from same affi just add them
          if $affi_sep.one_affi(temp_split) then
            affi_items[indx] = temp_split
          # if they are from different affis then create two?
          end
        # if the element can be added to current then just add
        elsif affi_items[indx] != nil
          current = affi_items[indx]
	  if current.keys.to_set.disjoint?temp_split.keys.to_set
	      # see if they can be in same affi
	      temp_affi = current.merge(temp_split)
        #      print "\nTemporary merge:" + temp_affi.to_s
	      if $affi_sep.one_affi(temp_affi)
		 affi_items[indx] = temp_affi
	      else
		# the new set of strings does not fit into current affi
                add_another = true
              end
	  else
	     # the new set of strings has keys already present in current affi
	     add_another = true
          end
        end
        if add_another
          indx += 1
          affi_items[indx] =  temp_split
        end
      end
      return affi_items
    end

    # split an affiliation string using the keywords lists before building an
    # affiliation object
    def split_by_keywords3(affi_string)
      # get the indexes of each element found
      # separate the string using the indexes
      kw_indexes = {} #keywords array of indexes and lengths
      found_inst = found_country = nil
      found_inst = $affi_sep.get_institution(affi_string)
      if found_inst != nil then
        kw_indexes[affi_string.index(found_inst)] = [found_inst.length, 'institution']
      end
      if found_inst == nil then
        found_inst = $affi_sep.get_institution_synonym(affi_string)
        if found_inst != nil then
          kw_indexes[affi_string.index(found_inst)] = [found_inst.length, 'inst_syn']
        end
      end
      found_country = $affi_sep.get_country(affi_string)
      if found_country != nil and affi_string.index(found_country)!=nil then
        kw_indexes[affi_string.index(found_country)] = [found_country.length, 'country']
      end
      found_country_synonym = $affi_sep.get_country_synonym(affi_string)
      if found_country_synonym != nil then
        cleared_affi_string = $affi_sep.country_exclude(affi_string)
	      diff = affi_string.length - cleared_affi_string.length
        kw_indexes[cleared_affi_string.index(found_country_synonym)+diff] = [found_country_synonym.length, "ctry_syn"]
      end
      found_faculty = $affi_sep.get_faculty(affi_string)
      if found_faculty != nil then
        kw_indexes[affi_string.index(found_faculty)] = [found_faculty.length, "faculty"]
      end
      found_workgroup = $affi_sep.get_workgroup(affi_string)
      if found_workgroup != nil then
        kw_indexes[affi_string.index(found_workgroup)] = [found_workgroup.length, "workgroup"]
        print "WORKGROUP FOUND"
        if $affi_sep.is_simple(affi_string) and affi_string == found_workgroup then
          return {"workgroup" => found_workgroup}
        end
      end
      found_department = $affi_sep.get_department(affi_string)
      if found_department != nil then
        kw_indexes[affi_string.index(found_department)] = [found_department.length,"department"]
      end

      print (kw_indexes)
      affiliation_array = {}
      prev_split = 0
      if kw_indexes.count > 0 then
        temp_affi = affi_string
        # Order the indexes to break the affi_string in its original order
        kw_indexes = kw_indexes.sort.to_h
        #check for overlaps in ordered indexes
        kw_indexes = remove_overlaps(kw_indexes)
        kw_indexes.keys.each do |kw_idx|
          # if the first index 0 make it the first element of the return array
          if affiliation_array == [] and kw_idx == 0 then
            affiliation_array = [temp_affi[kw_idx, kw_indexes[kw_idx][0]]]
          elsif affiliation_array == [] then
            affiliation_array = [temp_affi[..kw_idx-1]]
            affiliation_array.append(temp_affi[kw_idx, kw_indexes[kw_idx][0]])
          elsif prev_split < kw_idx then
            affiliation_array["ft_"+prev_split.to_s] = temp_affi[prev_split..kw_idx-1].strip
            affiliation_array[kw_indexes[kw_idx][1]] = temp_affi[kw_idx,kw_indexes[kw_idx][0]]
          else
            affiliation_array[kw_indexes[kw_idx][1]] = temp_affi[kw_idx,kw_indexes[kw_idx][0]]
          end
          prev_split = kw_idx + kw_indexes[kw_idx][0]
        end
      end
      # strip and remove trailing commas or semicolons
      affiliation_array = $affi_sep.remove_trailing(affiliation_array)
      # strip and remove leading commas or semicolons
      affiliation_array = $affi_sep.remove_leading(affiliation_array)
      # remove redundant splits (lone conectors e.g. 'and' or empty strings '')
      affiliation_array = $affi_sep.remove_redundant(affiliation_array)
      printf "\nAFFILIATION ARRAY: " + affiliation_array.to_s
      if affiliation_array.keys.include?("inst_syn")
        print "\nFound at "+ affiliation_array.keys.index("inst_syn").to_s
	      print "\nItem Found: "+ affiliation_array[0].to_s
        new_array = {}
        inst_full=$affi_sep.get_institution_from_synonym(affiliation_array["inst_syn"])
	      affiliation_array.each {|k,v| k=="inst_syn"? new_array["institution"] = inst_full:new_array[k] = v }
	      affiliation_array = new_array
        #affiliation_array.keys[0] = "institution"
        #affiliation_array.values[0] = inst_full
        #affiliation_array["institution"] = $affi_sep.get_institution_from_synonym(affiliation_array["inst_syn"])
	      #affiliation_array.delete("inst_syn")
      end
      #printf "\n****************************************************************\n"
      printf "\n" + affiliation_array.to_s
      #printf "\n****************************************************************\n"
      #
      return affiliation_array
    end
