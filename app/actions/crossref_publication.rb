# app/actions/crossref_publication.rb

# custom class for mapping crossref data to the database (rails models)
# publication is the base class which contains:
#   - publication details (journal, editon, publication date, etc)
#   - author details (name, orcid, affilition, etc.)
#   - affilition details (name, address, country, etc.)
class CrossrefPublication
  # verify article object agains CR record
  def self.verify_article(article)
    # get the article from crossref
    puts "** Verifying this: " + article.title
    digital_object_identifier = article.doi
    pub_data = CrossrefApiClient.getCRData(digital_object_identifier)
    if pub_data != nil
      art_id = article.id
      changes_found = false
      # only verify fields which may chenge between recoveries: citations
      if article.attributes['referenced_by_count'] != pub_data['is-referenced-by-count']
        changes_found = true
        article.attributes['referenced_by_count'] = pub_data['is-referenced-by-count']
        article.referenced_by_count = pub_data['is-referenced-by-count']
      end
      if changes_found
        article.save
      end
      aut_order = 1
      pub_data['author'].each do |art_author|
        changes_found = false
        new_author = ArticleAuthor.new()
        if art_id != nil
          tem_auth = ArticleAuthor.find_by article_id: art_id, author_order: aut_order
          if tem_auth != nil
            new_author = tem_auth
          end
        end
        if art_author.keys.include?('ORCID')
          if  new_author.orcid != art_author['ORCID']
            changes_found = true
            new_author.orcid = art_author['ORCID']
          end
        end
        if art_author.keys.include?('family')
          if new_author.last_name != art_author['family']
            changes_found = true
            new_author.last_name = art_author['family']
          end
        end
        if art_author.keys.include?('given')
          if new_author.given_name != art_author['given']
            changes_found = true
            new_author.given_name = art_author['given']
          end
        end
        if changes_found
          new_author.save
        end
        aut_id = new_author.id
        if art_author.keys.include?('affiliation')
          if art_author['affiliation'].length > 0
            art_author['affiliation'].each do |temp_affi|
              new_affi = CrAffiliation.new()
              affi_text = temp_affi['name']
              if aut_id != nil
                tem_affi = CrAffiliation.find_by article_author_id: aut_id, name: affi_text
                if tem_affi != nil
                  new_affi = tem_affi
                else
                  new_affi.name = temp_affi['name']
                  new_affi.article_author_id = aut_id
                  new_affi.save
                end
              end
            end
          end
        end
        aut_order += 1
      end
    end
  end

  def self.generate_author_affiliations(authors_list)
    affi_separator = AffiliationLists.new()
    authors_list.each do |an_author|
      article_authors = an_author.article_authors
      article_authors.each do |an_art_aut|
        continue = false
        affi_lines = an_art_aut.cr_affiliations.where(author_affiliation_id: nil)
        if affi_lines.length > 0
          #puts "Afiliatios for Article " + an_art_aut.article_id.to_s + ": "+ affi_lines.length.to_s
          #if affi_lines.count > 4
            return_hash = affi_separator.one_by_one_affi(affi_lines)
            puts "\n***********************************************************"
            puts "*Author: " + an_art_aut.id.to_s + " Lines: " + affi_lines.count.to_s
            puts "*input lines: "
            affi_separator.print_lines(affi_lines)
            print "\n*RETURN HASH " + return_hash.to_s
            n_affis = affi_separator.build_and_save_auth_affis(return_hash, an_art_aut.id)
            print "\n*New affilaitions saved: " + n_affis.to_s
            puts "\n***********************************************************"
          #end
        end
      end
    end
  end

  class AffiliationLists
    attr_accessor :affi_countries, :affi_institutions, :affi_work_groups,
      :affi_departments, :affi_faculties
    # lists of institution entities (affiliations in old model) as class
    # attributes
    @affi_countries = []
    @affi_institutions = []
    @affi_departments = []
    @affi_faculties = []
    @affi_work_groups = []
    def initialize()
      @affi_countries = Affiliation.distinct.pluck(:country)
      @affi_institutions = Affiliation.distinct.pluck(:institution)
      @affi_departments = Affiliation.where('department IS NOT NULL').distinct.pluck(:department)
      @affi_faculties = Affiliation.where('faculty IS NOT NULL').distinct.pluck(:faculty)
      @affi_work_groups = Affiliation.where('work_group IS NOT NULL').distinct.pluck(:work_group)

      # list of country sysnonyms
      # (need to persist somewhere)
      @country_synonyms = {"(UK)":"United Kingdom", "UK":"United Kingdom",
        "U.K.":"United Kingdom", "U. K.":"United Kingdom",
        "U.K":"United Kingdom", "PRC":"Peoples Republic of China",
        "P.R.C.":"Peoples Republic of China", "China":"Peoples Republic of China",
        "P.R.China":"Peoples Republic of China",
        "P.R. China":"Peoples Republic of China",
        "United States":"United States of America",
        "USA":"United States of America","U.S.A.":"United States of America",
        "U. S. A.":"United States of America", "U.S.":"United States of America",
        "U. S.":"United States of America","US":"United States of America"}

      # list of institution sysnonyms
      # (need to persist somewhere)
      @institution_synonyms = {"The ISIS facility":"ISIS Neutron and Muon Source",
        "ISIS Neutron and Muon Facility":"ISIS Neutron and Muon Source",
        "STFC":"Science and Technology Facilities Council",
        "Oxford University":"University of Oxford",
        "University of St Andrews":"University of St. Andrews",
        "Diamond Light Source Ltd Harwell Science and Innovation Campus":"Diamond Light Source Ltd.",
        "Diamond Light Source":"Diamond Light Source Ltd.",
        "ISIS Facility":"ISIS Neutron and Muon Source",
        "University College of London":"University College London",
        "UOP LLC":"UOP LLC, A Honeywell Company",
        "University of Manchester":"The University of Manchester",
        "Johnson-Matthey Technology Centre":"Johnson Matthey Technology Centre",
        "Research Complex at Harwell (RCaH)":"Research Complex at Harwell",
        "RCaH":"Research Complex at Harwell",
        "Queens University Belfast":"Queen's University Belfast",
        "University of Edinburgh":"The University of Edinburgh"
      }

      # list of institutions hosted by other institutions
      # institution1:institution2 => institution1 is hosted by institution2
      # (need to persist somewhere)
      @institution_hostings = {
        "ISIS Neutron and Muon Source":"Science and Technology Facilities Council",
        "Diamond Light Source Ltd.":"Science and Technology Facilities Council",
        "Research Complex at Harwell":"Science and Technology Facilities Council",
        "UK Catalysis Hub":"Research Complex at Harwell",
        "HarwellXPS":"Research Complex at Harwell",
        "Cardiff Catalysis Institute":"Cardiff University"
      }

      # list ofstrings which contain country names but are not countries, such as
      # streets, institution names, etc.
      # (need to persist somewhere)
      @country_exceptions = ["Denmark Hill", "UK Catalysis Hub", "Sasol Technology U.K.", "N. Ireland"]
    end

    # create a new affiliation object from a list of string values
    def create_affi_obj(lines_list, auth_id, affi_id)
      line_idx = 0
      auth_affi = AuthorAffiliation.new()
      auth_affi.article_author_id = auth_id
      auth_affi.affiliation_id = affi_id
      inst_found = ""

      while line_idx < lines_list.count
        a_line = lines_list[line_idx].strip
        # first element is designated as the affilition
        if line_idx == 0
          auth_affi.name = a_line
        elsif @affi_countries.include?(a_line)
          auth_affi.country = a_line
        elsif @affi_institutions.include?(a_line) and auth_affi.name != nil then
          # if the affiliation name is not an institution
          # add institution to name and make short name the institution
          # otherwise shot name is the same as name
          if @affi_institutions.include?(auth_affi.name) or \
            @institution_synonyms.keys.include?(auth_affi.name.to_sym) then
            auth_affi.short_name = auth_affi.name
            auth_affi.add_01 = a_line
          else
            auth_affi.name = auth_affi.name + ", " + a_line
            auth_affi.short_name = a_line
          end
        elsif @institution_synonyms.keys.include?(a_line.to_sym) and \
          auth_affi.name != nil then
          # if the affiliation name is not an institution
          # add institution to name and make short name the institution
          # otherwise shot name is the same as name
          if @affi_institutions.include?(auth_affi.name) or \
            @institution_synonyms.keys.include?(auth_affi.name.to_sym) then
            auth_affi.short_name =  auth_affi.name
            auth_affi.add_01 = a_line
          else
            auth_affi.name = auth_affi.name + ", " + @institution_synonyms[a_line.to_sym]
            auth_affi.short_name =  @institution_synonyms[a_line.to_sym]
          end
        elsif auth_affi.add_01 == nil
          auth_affi.add_01 = a_line
        elsif auth_affi.add_02 == nil
          auth_affi.add_02 = a_line
        elsif auth_affi.add_03 == nil
          auth_affi.add_03 = a_line
        elsif auth_affi.add_04 == nil
          auth_affi.add_04 = a_line
        elsif auth_affi.add_05 == nil
          auth_affi.add_05 = a_line
        elsif auth_affi.add_05 != nil # case more than 5 tokes in address
          auth_affi.add_05 += ", " + a_line
        end
        line_idx += 1
      end

      # make sure there is a short name, if blank make it the same as name
      if auth_affi.short_name == nil
        auth_affi.short_name = auth_affi.name
      end

      # if country is missing get check all addres lines in object
      if auth_affi.country.to_s == ""
        auth_affi.attributes.keys.each do |instance_variable|
          # look for country name in address strings
          if instance_variable.to_s.include?("add_0") then
            #print instance_variable
            value = auth_affi.attributes[instance_variable]
            ctry = get_country(value.to_s)
            if ctry != nil then
              auth_affi.country = ctry
              value = drop_country(value)
              auth_affi.attributes[instance_variable] = value
              break
            end
          end
        end
        # look for country in affiliation name
        if auth_affi.country.to_s == ""  then
          ctry = get_country(auth_affi.name)
          auth_affi.country = ctry
        end
        # look for country in institution table
        if auth_affi.country.to_s == ""  then
          inst_found = auth_affi.name
          if @affi_institutions.include?(auth_affi.name) then
            inst_found = auth_affi.name
            ctry = Affiliation.find_by(institution: inst_found.strip).country
            auth_affi.country = ctry
          elsif @affi_institutions.include?(auth_affi.short_name) then
            inst_found = auth_affi.short_name
            ctry = Affiliation.find_by(institution: inst_found.strip).country
            auth_affi.country = ctry
          elsif @institution_synonyms.keys.include?(auth_affi.name.to_sym)
            inst_found = @institution_synonyms[auth_affi.name.to_sym]
            ctry = Affiliation.find_by(institution: inst_found.strip).country
            auth_affi.country = ctry
          elsif @institution_synonyms.keys.include?(auth_affi.short_name.to_sym)
            inst_found = @institution_synonyms[auth_affi.short_name.to_sym]
            ctry = Affiliation.find_by(institution: inst_found.strip).country
            auth_affi.country = ctry
          end
        end
      end
      return auth_affi
    end

    # if a value in the country exeptions list is in string, remove that value
    # before looking up for country
    def country_exclude(affi_string)
      @country_exceptions.each do |not_a_country|
        if affi_string.include?(not_a_country)
          return affi_string.gsub(not_a_country, "")
        end
      end
      # if notting is removed
      return affi_string
    end

    # if a value in the country or country sysnonyms lists is in string, return that
    # value (verify first that there are no country exceptions in string)
    def get_country(affi_string)
      cleared_affi_string = country_exclude(affi_string)
      @affi_countries.each do |country|
        if cleared_affi_string.include?(country)
          return country
        end
      end
      @country_synonyms.keys.each do |ctry_key|
        if cleared_affi_string.include?(ctry_key.to_s)
          return @country_synonyms[ctry_key]
        end
      end
      return nil
    end

    # if a value in the country sysnonyms lists is in string, return that value
    def get_country_synonym(affi_string)
      cleared_affi_string = country_exclude(affi_string)
      @country_synonyms.keys.each do |ctry_key|
        if cleared_affi_string.include?(ctry_key.to_s)
          return ctry_key.to_s
        end
      end
      return nil
    end

    # get the country corresponding to the country synonym
    def get_country_from_synonym(ctry_synonym)
      return @country_synonyms[ctry_synonym.to_sym]
    end

    # if a value in the country or country sysnonyms lists is in string, remove that
    # value from the string
    def drop_country(affi_string)
      dropped_country = affi_string
      @affi_countries.each do |country|
        if dropped_country.include?(country)
          dropped_country = dropped_country.gsub(country,"").strip
        end
      end
      @country_synonyms.keys.each do |ctry_key|
         if affi_string.include?(ctry_key.to_s)
           dropped_country = dropped_country.gsub(ctry_key.to_s,"").strip
         end
      end
      return dropped_country
    end

    # if a value in the institutions list is in string, return that value
    def get_institution(affi_string)
      found_inst = nil
      @affi_institutions.each do |inst_key|
        if affi_string.include?(inst_key.to_s) then
          if found_inst == nil then
            found_inst = inst_key.to_s
          elsif found_inst != nil and found_inst.length < inst_key.to_s.length then
            found_inst = inst_key.to_s
          end
        end
      end
      return found_inst
    end

    # if a value in the institution sysnonyms list is in string, return that value
    def get_institution_synonym(affi_string)
      found_inst = nil
      @institution_synonyms.keys.each do |inst_key|
        if affi_string.include?(inst_key.to_s) then
          if found_inst == nil then
            found_inst = inst_key.to_s
          elsif found_inst != nil and found_inst.length < inst_key.to_s.length then
            found_inst = inst_key.to_s
          end
        end
      end
      return found_inst
    end

    # get the institution name corresponding to the institution synonym
    def get_institution_from_synonym(inst_synonym)
      return @institution_synonyms[inst_synonym.to_sym]
    end

    # if a value in the departments list is in string, return that value
    def get_department(affi_string)
      found_dep = nil
      @affi_departments.each do |department|
        if affi_string.include?(department) then
          if found_dep == nil then
            found_dep = department
          elsif found_dep != nil and found_dep.length < department.length then
            found_dep = department
          end
        end
      end
      return found_dep
    end

    # if a value in the faculties list is in string, return that value
    def get_faculty(affi_string)
      found_fac = nil
      @affi_faculties.each do |faculty|
        if affi_string.include?(faculty)
          if found_fac == nil then
            found_fac = faculty
          elsif found_fac.length < faculty.length then
            found_fac = faculty
          end
        end
      end
      return found_fac
    end

    # if a value in the workgroups list is in string, return that value
    def get_workgroup(affi_string)
      found_wg = nil
      @affi_work_groups.each do |workgroup|
        if affi_string.include?(workgroup) then
          if found_wg == nil then
            found_wg = workgroup
          elsif found_wg != nil and found_wg.length < workgroup.length then
            found_wg = workgroup
          end
        end
      end
      return found_wg
    end

    # split affiliation strings with keywords lists before building affi objects
    def split_by_keywords(affi_string)
      # get the indexes of each element found
      # separate the string using the indexes
      kw_indexes = {} #keywords array of indexes and lengths
      found_inst = found_country = nil
      found_inst = get_institution(affi_string)
      if found_inst != nil then
        kw_indexes[affi_string.index(found_inst)] = [found_inst.length, 'institution']
      end
      if found_inst == nil then
        found_inst = get_institution_synonym(affi_string)
        if found_inst != nil then
          kw_indexes[affi_string.index(found_inst)] = [found_inst.length, 'inst_syn']
        end
      end
      found_country = get_country(affi_string)
      if found_country != nil and affi_string.index(found_country)!=nil then
        kw_indexes[affi_string.index(found_country)] = [found_country.length, 'country']
      end
      found_country_synonym = get_country_synonym(affi_string)
      if found_country_synonym != nil then
        cleared_affi_string = country_exclude(affi_string)
	      diff = affi_string.length - cleared_affi_string.length
        kw_indexes[cleared_affi_string.index(found_country_synonym)+diff] = [found_country_synonym.length, "ctry_syn"]
      end
      found_faculty = get_faculty(affi_string)
      if found_faculty != nil then
        kw_indexes[affi_string.index(found_faculty)] = [found_faculty.length, "faculty"]
      end
      found_workgroup = get_workgroup(affi_string)
      if found_workgroup != nil then
        kw_indexes[affi_string.index(found_workgroup)] = [found_workgroup.length, "work_group"]
        if is_simple(affi_string) and affi_string == found_workgroup then
          return {"work_group" => found_workgroup}
        end
      end
      found_department = get_department(affi_string)
      if found_department != nil then
        kw_indexes[affi_string.index(found_department)] = [found_department.length,"department"]
      end

      affiliation_array = {}
      prev_split = 0
      if kw_indexes.count > 0 then
        temp_affi = affi_string
        # Order the indexes to break the affistring in its original order
        kw_indexes = kw_indexes.sort.to_h
        # check for overlaps in ordered indexes and remove them
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
      affiliation_array = remove_trailing(affiliation_array)
      # strip and remove leading commas or semicolons
      affiliation_array = remove_leading(affiliation_array)

      # remove redundant splits (lone conectors e.g. 'and' or empty strings '')
      affiliation_array = remove_redundant(affiliation_array)
      if affiliation_array.keys.include?("inst_syn")
        new_array = {}
        inst_full = get_institution_from_synonym(affiliation_array["inst_syn"])
        affiliation_array.each {|k,v|
          k=="inst_syn"? new_array["institution"] = inst_full:new_array[k] = v }
        affiliation_array = new_array
      end
      return affiliation_array
    end

    #remove overlaping instances from found keyword hash (helper for split by keywords)
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
    def one_by_one_affi(affi_lines, accummulated = [])
      # split the first line
      # add it to affi_lines if affi_lines empty
      # in next line try to see if the string belongs to same affiliation
      # after first line try adding to affi_hash, if resulting in same affi, add, else start new affi_hash item
      affi_hash = {}
      indx = 0
      other_lines = 1
      affi_hash[indx] = nil
      temp_pair = []
      affi_lines.each do |cr_affi|
        # split element by keywords
        temp_split = split_by_keywords(cr_affi.name.strip)#.gsub("'","''"))
        # when no fragment is recognised as a keyword?
        if temp_split == {} then
          temp_split = {"line_"+other_lines.to_s => cr_affi.name.strip}
          other_lines += 1
        end
        #   - test if current affiliation is full (i.e. inst, dep, fcty, wg, cty.)
        #     or already contains the elements just returned
        #     - not complete then test if it fits with current affiliation
        #       - if an affi is element already filled then mark current affi as
        #         - complete and create a new affi.
        #           - mark as complete requires looking for matches and missing minimal parts in affiliations table: i.e. inst, ctry,
        #           - if inst and ctry blank, use the same as last one (i.e. inst and ctry from previous)

        # currently there is no affiliation
        add_another = false
        if affi_hash[indx] == nil then
          # if all elements are from same affi just add them
          if one_affi(temp_split) then
            affi_hash[indx] = [temp_split,[cr_affi.id]]
          # if they are from different affis then create two?
          end
        # if the element can be added to current then just add
        elsif affi_hash[indx] != nil
          current_pair = affi_hash[indx]
          if current_pair[0].keys.to_set.disjoint?(temp_split.keys.to_set)
          # see if they can be in same affi merge and see if it works
            temp_pair = [current_pair[0].merge(temp_split),current_pair[1].append(cr_affi.id)]
            if one_affi(temp_pair[0])
              affi_hash[indx] = temp_pair
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
          affi_hash[indx] =  [temp_split,[cr_affi.id]]
        end
      end
      return affi_hash
    end

    # delete trailing commas or semicolons
    def remove_trailing(x_hash)
      x_hash.each do |ex|
        x_hash[ex[0]] = x_hash[ex[0]].strip.chomp(",").chomp(";")
      end
      return x_hash
    end

    # delete leading commas or semicolons
    def remove_leading(x_hash)
      x_hash.each do |ex|
        if x_hash[ex[0]][0] == ";" or x_hash[ex[0]][0] == "," then
           x_hash[ex[0]] = x_hash[ex[0]][1..].strip()
        end
      end
      return x_hash
    end

    def remove_redundant(x_hash)
      redundant_strings = ["", "and", "The"]
      red_found_at = []
      x_hash.each do |ex|
        if redundant_strings.include?(ex[1].to_s) then
          red_found_at.append(ex[0])
       end
      end
      red_found_at.each do |red_key|
        x_hash.delete(red_key)
      end
      return x_hash
    end

    # verify if the affiliation object is well formed it should have a country,
    # a name and a valid author ID
    # (make into a method of the affi_object)
    def affi_object_well_formed(affi_object, name_list, auth_id)
      # problem: affi_object nil
      if affi_object == nil
        puts "\n********************* Affiliation is nil **********************\n"
        name_list.each do |cr_affi|
          puts cr_affi.id.to_s + " - " + cr_affi.name
        end
        return false
      # problem: missing country
      elsif affi_object.country == nil
        puts "\n************************Missing country**********************"
        printf("\nAuthor %d affilition parsed\n", auth_id)
        print_affi(affi_object)
        puts name_list
        return false
      # problem: missing name
      elsif affi_object.name == nil
        puts "\n************************ Missing name **********************"
        printf("\n*Author %d affilition parsed\n", auth_id)
        print_affi(affi_object)
        puts name_list.name
        return false
      # problem: missing author or author_affiliation_id incorrect
      elsif affi_object.article_author_id == nil or \
        affi_object.article_author_id != auth_id
        puts "\n************************ Wrong Author ID **********************"
        printf("\n*Author %d affilition parsed\n", auth_id)
        print_affi(affi_object)
        print name_list
        return false
      else
        return true
      end
    end

    # determine if an affilition string is simple by checking if it fully matches
    # one of the keywords from the common lists
    def is_simple(an_item)
      #verify if item has two or more affilition elements
      items_found={}
      items_found["institution"] = get_institution(an_item)
      items_found["department"] = get_department(an_item)
      items_found["faculty"] = get_faculty(an_item)
      items_found["work_group"] = get_workgroup(an_item)
      items_found["country"] = get_country(an_item)
      # item matches exactly one of the found values so it is simple
      items_found.values.each do |found_this|
        if found_this != nil and found_this.downcase().strip == an_item.downcase().strip then return true end
        if found_this != nil and found_this.length > an_item.length then return true end # found a synonym
      end
      return false
    end

    def one_affi(affi_hash)
      valid_keys = ["institution","work_group","department","faculty","country"]
      find_str = ""
      affi_hash.keys.each do |item_key|
        if affi_hash[item_key].to_s != "" and valid_keys.include?(item_key.to_s)
          find_str += item_key.to_s + " = '" + affi_hash[item_key].gsub("'","''") + "' and "
        end
      end
      if find_str != "" then
        find_str = find_str[..-5]
        found = Affiliation.where(find_str).count
        if found > 0 then
          return true
        end
      end
      return false
    end

    # analise the affi hashes and determine if they belong to a single or various
    # affiliations. Last step before actually building the affiliations
    def build_and_save_auth_affis(new_affi_hash, auth_id = 0)
      # new_affi_hash = { 0 => [{"institution" => "Diamond Light Source Ltd.",
      #                       "ft_20" => "Harwell Science and Innovation Campus Didcot OX11 0DE",#
      #                       "ctry_syn" => "UK"},[139]],
      #                 1 => [{"department" => "Department of Chemistry",
      #                       "institution"=>"University of Reading",
      #                       "ft_44"=>"Reading RG6 6AD",
      #                       "ctry_syn"=>"UK"}},[140]]
      affis_built = 0
      if new_affi_hash.count > 0 then
        affi_previous = nil
        previous = nil
        previous_ids = nil
        build_affis={}
        new_affi_hash.each { |k,vs|
          current = vs[0] # get the values of current affi
          current_ids = vs[1]
          affi_current = get_affi(current)
          if previous != nil and current != nil then
            if affi_current != nil
              curr_inst = affi_current.institution.strip
              prev_inst = affi_previous.institution.strip
              if @institution_hostings[prev_inst.to_sym] == curr_inst then
                # prev_inst is hosted by curr_inst
                # create single affi for prev_inst, appending values of current
                # merge previous_ids to current_ids
                current_ids = previous_ids.to_set.union(current_ids.to_set).to_a
                build_affis[affi_previous.id] = [previous.values + current.values, current_ids]
                # skip current in next loop by making previous = current
                current = previous
              elsif @institution_hostings[curr_inst.to_sym] == prev_inst then
                # curr_inst is hosted by prev_inst
                # create single affi for curr_inst, appending values of previous
                # merge previous_ids to current_ids
                previous_ids = previous_ids.set.union(current_ids.set).to_a
                build_affis[affi_previous.id] = [current.values + previous.values, previous_ids]
              else
                # curr_inst and prev_inst are independent
                # create an affi for each
                if build_affis[build_affis.count - 1] == nil \
                   or !build_affis[build_affis.count -1][0].include?(affi_previous.institution) then
                  build_affis[affi_previous.id] = [previous.values, previous_ids]
                elsif !build_affis.keys.include?(affi_previous.id) then
                  build_affis[affi_previous.id] = [previous.values, previous_ids]
                end
                build_affis[affi_current.id] = [current.values, current_ids]
              end
            else
              print "\n********************************************************"
              print "\n problem with current:  " + current.to_s
              print "\n Previous:      " + previous.to_s
              print "\n Previous affi: " + affi_previous.id.to_s
              print "\n Lines:         " + new_affi_hash.to_s
              print "\n********************************************************"
              # Rescue the portion which is OK
              if affi_previous != nil then
                  build_affis[affi_previous.id] = [previous.values, previous_ids]
              end
            end
          end
          print "\n********************************************************"
          print "\n" + build_affis.to_s
          print "\n" + current.to_s
          print "\n********************************************************"
          previous = current
          previous_ids = current_ids
          affi_previous = affi_current
        }
        if build_affis.count == 0 then
          # there was only one affiliation in hash, build it
          build_affis[affi_previous.id] = [previous.values, previous_ids]
        end
        print "\n********************************************************"
        print "\n" + build_affis.to_s
        print "\n********************************************************"

        # Save in DB
        build_affis.each{|affi_id, lines_list|
          affi_obj = create_affi_obj(lines_list[0], auth_id, affi_id)
          continue = affi_object_well_formed(affi_obj, lines_list[0], auth_id)
          # save the object
          if continue then
            puts "\nAffiliation object is well formed"
            existing_affi = AuthorAffiliation.find_by(article_author_id: auth_id, name:affi_obj.name)
            if existing_affi == nil then
              puts "\nSaving Affiliation"
              affi_obj.save
              # mark the cr_affis with the id of the corresponding author_affiliation
              cr_affis = lines_list[1]
              cr_affis.each {|cr_affi_id|
                cr_affi = CrAffiliation.find(cr_affi_id)
                cr_affi.author_affiliation_id = affi_obj.id
                cr_affi.save
              }
              affis_built += 1
            else
              puts "Found existing affiliation: " + existing_affi.id.to_s
            end
          else
            puts "**Found error in new affiliation**"
            print_affi(affi_obj)
            print build_affis.to_s
            puts "**********************************"
          end
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
        ctry_name = get_country_from_synonym(affi_hash["ctry_syn"])
        find_str += "country = '" + ctry_name.gsub("'","''") + "' and "
      end
      if find_str != "" then
        find_str = find_str[..-5]
        found_affis = Affiliation.where(find_str)
        if found_affis.count > 0 then
          if found_affis.count == 1 then
            return found_affis[0]
          else
            # Determine which is the closest match for the affi at hand
            candidate_scores = {}
            affi_index = 0
            relevant_keys = affi_hash.keys.to_set().intersection(valid_keys.to_set())
            exclude_keys = valid_keys.to_set() - affi_hash.keys.to_set()
            found_affis.each do |an_affi|
              # check if affi matches only relevant and does not have other
              # fields filled.
              # LOOKING FOR relevant_keys
              # IGNORING exclude_keys.to_s
              likely_candidate = 0
              exclude_keys.each {|key|
                if an_affi.attributes[key].to_s == "" then
                  likely_candidate  += 1
                end
              }
              candidate_scores[affi_index] = likely_candidate
              affi_index+=1
            end
            # get the higuest scoring match, i.e. the most similar found
            candidate_scores = candidate_scores.sort_by{|k,v| v}.reverse()
            max = candidate_scores[0][1]
            maxes = 1
            candidate_scores.each {|c_pair|
              if c_pair[0] !=0 and c_pair[1] == max then
                maxes += 1
              end
            }
            print "\nCandidate Scores: " + candidate_scores.to_s
            print "\nMaxes: " + maxes.to_s
            if maxes <= 3 then
               high_score = candidate_scores[0][0]
               print "\nFound Affis: " + found_affis[high_score].id.to_s
               return found_affis[high_score]
            else
               return nil
            end
          end
        end
      end
    end

    # print the contents of the affiliation object
    def print_affi(affi_object)
      printf "\nAuthor ID: %d affiliation: %s affiliation short: %s country: %s\n", affi_object.article_author_id, affi_object.name, affi_object.short_name, affi_object.country
      printf "\nAddress: %s, %s, %s, %s, %s\n", affi_object.add_01, affi_object.add_02, affi_object.add_03,affi_object.add_04, affi_object.add_05
    end

    # print CR affi lines
    def print_lines(affi_lines)
       affi_lines.each do |cr_affi|
         print "\n\t" + cr_affi.name
       end
    end
  end
end
