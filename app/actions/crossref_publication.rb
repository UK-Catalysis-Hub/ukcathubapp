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

  def self.verify_author_affiliations(authors_list)
    al_obj = AffiliationLists.new()
    # print "\nCountries: " + al_obj.affi_countries.to_s
    # print "\nInstitutions: " + al_obj.affi_institutions.to_s
    # print "\nDepartments: " + al_obj.affi_departments.to_s
    # print "\nFaculties: " + al_obj.affi_faculties.to_s
    # print "\nWorkgroups: " + al_obj.affi_work_groups.to_s
    authors_list.each do |an_author|
      puts "\n" + an_author.last_name
      article_authors = an_author.article_authors
      puts "Articles authored: " +  article_authors.length.to_s
      article_authors.each do |an_art_aut|
        split_complex = false
        continue = false
        affi_lines = an_art_aut.cr_affiliations
        puts "Afiliatios for " + an_art_aut.article_id.to_s + ": "+ affi_lines.length.to_s
        if affi_lines.count == 1
          al_obj.build_complex(affi_lines, an_art_aut.id )
        elsif affi_lines.count > 1
          # check if lines there is one or more than one affiliations in string
          print " Has Many affiliation lines\n"
          # check if affiliation lines contain more than one affiliation
          single_ctr = 0
          affi_lines.each do |cr_affi|
            if al_obj.is_simple(cr_affi.name) then
              #printf("\n%s Single", an_item)
              single_ctr += 1
            elsif al_obj.is_complex(cr_affi.name) then
              printf("\n%s Complex", cr_affi.name)
            else
              #printf("\n%s Single", an_item)
              single_ctr += 1
            end
          end
          if single_ctr > 1
            print "\t treat all cr as a single affi\n"
            al_obj.build_single(affi_lines, an_art_aut.id)
          else
            print "\t treat each cr as a complex affi\n"
            al_obj.build_complex(affi_lines, an_art_aut.id )
          end
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
      @country_synonyms = {"UK":"United Kingdom", "U.K.":"United Kingdom",
          "U. K.":"United Kingdom", "U.K":"United Kingdom",
          "PRC":"Peoples Republic of China", "P.R.C.":"Peoples Republic of China",
          "China":"Peoples Republic of China",
          "P.R.China":"Peoples Republic of China",
          "P.R. China":"Peoples Republic of China",
          "United States":"United States of America",
          "USA":"United States of America","U.S.A.":"United States of America",
          "U. S. A.":"United States of America", "U.S.":"United States of America",
          "U. S.":"United States of America","US":"United States of America"}

      # list of institution sysnonyms
      # (need to persist somewhere)
      @institution_synonyms = {"The ISIS facility":"ISIS Neutron and Muon Source",
          "STFC":"Science and Technology Facilities Councils",
          "Oxford University":"University of Oxford",
          "University of St Andrews":"University of St. Andrews",
          "Diamond Light Source":"Diamond Light Source Ltd.",
          "ISIS Facility":"ISIS Neutron and Muon Source"}

      # list ofstrings which contain country names but are not countries, such as
      # streets, institution names, etc.
      # (need to persist somewhere)
      @country_exceptions = ["Denmark Hill", "UK Catalysis Hub"]
    end

    # create a new affiliation object from a list of string values
    def create_affi_obj(lines_list, auth_id)
      line_idx = 0
      auth_affi = AuthorAffiliation.new()
      auth_affi.article_author_id = auth_id
      inst_found = ""

      while line_idx < lines_list.count
        a_line = lines_list[line_idx].strip
        # first element is designated as the affilition
        if line_idx == 0
          auth_affi.name = a_line
        elsif @affi_countries.include?(a_line)
          auth_affi.country = a_line
        elsif @affi_institutions.include?(a_line)
          if auth_affi.name != nil
            # if the affiliation name is not an institution
            # add institution to name and make short name the institution
            # otherwise shot name is the same as name
            if !@affi_institutions.include?(auth_affi.name) or \
              !@institution_synonyms.keys.include?(auth_affi.name.to_sym) then
              auth_affi.name = auth_affi.name + ", " + a_line
              auth_affi.short_name = a_line
            else
              auth_affi.short_name = auth_affi.name
            end
          end
        elsif @institution_synonyms.keys.include?(a_line.to_sym) then
          if auth_affi.name != nil
            # if the affiliation name is not an institution
            # add institution to name and make short name the institution
            # otherwise shot name is the same as name
            if !@affi_institutions.include?(auth_affi.name) and \
              !@institution_synonyms.keys.include?(auth_affi.name.to_sym) then
              auth_affi.name = auth_affi.name + ", " + @institution_synonyms[a_line.to_sym]
              auth_affi.short_name =  @institution_synonyms[a_line.to_sym]
            else
              auth_affi.short_name =  @institution_synonyms[a_line.to_sym]
            end
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
        # print auth_affi.country
        #
        if auth_affi.country.to_s == ""  then
          #printf "\n Before if %s", auth_affi.name
          inst_found = auth_affi.name
          if @affi_institutions.include?(auth_affi.name) or \
            @institution_synonyms.keys.include?(auth_affi.name.to_sym) then
            inst_found = auth_affi.name
            #printf "\n Before sendig %s", inst_found
            ctry = Affiliation.find_by(institution: inst_found.strip).country
            auth_affi.country = ctry
          elsif @affi_institutions.include?(auth_affi.short_name) or \
            @institution_synonyms.keys.include?(auth_affi.short_name.to_s.to_sym) then
            inst_found = auth_affi.short_name
            #printf "\n Before sendig %s", inst_found
            ctry = Affiliation.find_by(institution: inst_found.strip).country
            auth_affi.country = ctry
          end
        end
      end
      return auth_affi
    end

    # handle strings wich contain a complete affiliation
    def build_complex(affi_lines, art_aut_id )
      split_complex = true
      affi_lines.each do |cr_affi|
        affi_line_id =cr_affi.id
        affi_line_value = cr_affi.name
        auth_affi = split_complex(affi_line_value, art_aut_id)
        # check if object is well formed
        continue = affi_object_well_formed(auth_affi, affi_lines, split_complex, art_aut_id)
        # save the object
        if continue then
          puts "\nAffiliation object is well formed"
          existing_affi = AuthorAffiliation.find_by(article_author_id: auth_affi.article_author_id, name:auth_affi.name)
          if existing_affi == nil then
            puts "\nSaving Affiliation"
            auth_affi.save
            # mark the cr_affi with the id of the corresponding author_affiliation
            cr_affi.author_affiliation_id = art_aut_id
            cr_affi.save
          else
            puts "Found existing affiliation: " + existing_affi.id.to_s
          end
        end
      end
    end

    # handle affiliations consisting of many cr_affi lines
    def build_single(affi_lines, art_aut_id)
      split_complex = false
      cr_affi_keys = []
      single_vals = []
      affi_lines.each do |cr_affi|
        cr_affi_keys.append(cr_affi.id)
        single_vals.append(cr_affi.name)
      end
      auth_affi = create_affi_obj(single_vals, art_aut_id)
      # check if object is well formed
      continue = affi_object_well_formed(auth_affi, affi_lines, split_complex, art_aut_id)
      # save the object
      if continue then
        puts "\nAffiliation object is well formed"
        existing_affi = AuthorAffiliation.find_by(article_author_id: auth_affi.article_author_id, name:auth_affi.name)
        if existing_affi == nil then
          puts "\nSaving Affiliation"
          auth_affi.save
          # mark the cr_affis with the id of the corresponding author_affiliation
          affi_lines.each do |cr_affi|
            cr_affi.author_affiliation_id = auth_affi.id
            cr_affi.save
          end
        else
          puts "Found existing affiliation: " + existing_affi.id.to_s
        end
      end
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

    # determine if the string needs to be split by delimiters or by keywords and
    # call the corresponding method to build the affiliation object
    def split_complex(affi_string, auth_id)
      if affi_string.include?(",") or affi_string.include?(";")
        return split_by_separator(affi_string, auth_id)
      else
        return split_by_keywords(affi_string, auth_id)
      end
    end

    # split the affiliation string by "," and ";" separators
    def split_by_separator(affi_string, auth_id)
      tokens = []
      if affi_string.include?(",") and affi_string.include?(";")
        tokens = affi_string.split(";")
        tokens.each do |token|
          if token.include?(",")
            split_idx = tokens.find_index(token)
            temp_tkns = token.split(",")
            tokens = tokens[1..split_idx-1].concat(temp_tkns).concat(tokens[split_idx+1..])
          end
        end
      elsif affi_string.include?(",")
        tokens = affi_string.split(",")
      elsif affi_string.include?(";")
        tokens = affi_string.split(";")
      end
      # # how to handle a name which has both and institution and a another name?
      # # EXAMPLE " Department of Materials Science and Engineering Lehigh University"
      if tokens != []
        return create_affi_obj(tokens, auth_id)
      else
        return nil
      end
    end

    # if a value in the institutions list is in string, return that value
    def get_institution(affi_string)
      @affi_institutions.each do |institution|
        if affi_string.include?(institution)
          return institution
        end
      end
      return nil
    end

    # if a value in the institution sysnonyms list is in string, return that value
    def get_institution_synonym(affi_string)
      @institution_synonyms.keys.each do |inst_key|
        if affi_string.include?(inst_key.to_s)
          return inst_key.to_s
        end
      end
      return nil
    end

    # if a value in the departments list is in string, return that value
    def get_department(affi_string)
      @affi_departments.each do |department|
        if affi_string.include?(department)
          return department
        end
      end
      return nil
    end

    # if a value in the faculties list is in string, return that value
    def get_faculty(affi_string)
      @affi_faculties.each do |faculty|
        if affi_string.include?(faculty)
          return faculty
        end
      end
      return nil
    end

    # if a value in the workgroups list is in string, return that value
    def get_workgroup(affi_string)
      @affi_work_groups.each do |workgroup|
        if affi_string.include?(workgroup)
          return workgroup
        end
      end
      return nil
    end

    # split an affiliation string using the institution and country lists and then
    # build the object
    def split_by_keywords(affi_string, auth_id)
      # build affiliation object directly
      # try with country and institution
      # printf "\n************************** SPLITTING BY KEYWORD *****************\n"
      # printf "Affiliation: %s\n", affi_string
      tokens=[]
      found_inst = found_country = ""
      found_inst = get_institution(affi_string)
      if found_inst == nil then
        found_inst = get_institution_synonym(affi_string)
        #printf "Institution: %s\n", found_inst
      end
      found_country = get_country(affi_string)
      if found_inst.to_s != ""
        ins_idx = affi_string.index(found_inst)
        affi_len = affi_string.length
        inst_len = found_inst.length
        if ins_idx == 0
          tokens.append found_inst
          tokens.append drop_country(affi_string[inst_len, affi_len-inst_len].strip)
          tokens.append found_country
          affi_rest = affi_string[inst_len-1, affi_len-inst_len].strip
        else
          tokens.append affi_string[0, ins_idx].strip
          tokens.append found_inst
          tokens.append drop_country(affi_string[affi_string[ins_idx+inst_len, affi_len-inst_len].strip].strip)
          tokens.append found_country
        end
        # printf"\n****************************************************************\n"
        # print tokens
        # printf"\n****************************************************************\n"
        affi_obj = create_affi_obj(tokens, auth_id)
        return affi_obj
      end
    end
    # verify if the affiliation object is well formed it should have a country,
    # a name and a valid author ID
    # (make into a method of the affi_object)
    def affi_object_well_formed(affi_object, name_list, parsed_complex, auth_id)
      # problem: affi_object nil
      if affi_object == nil
        puts "\n********************* Affiliation is nil **********************\n"
        puts name_list
      # problem: missing country
      elsif affi_object.country == nil
        if parsed_complex == false
          printf("\nAuthor %d affilition parsed as complex \n", auth_id)
        else
          printf("\nAuthor %d affilition parse as single \n", auth_id)
        end
        puts "\n************************Missing country**********************\n"
        print_affi(affi_object)
        puts name_list
        return false
      # problem: missing name
      elsif affi_object.name == nil
        if parsed_complex == false
          printf("\nAuthor %d affilition parsed as complex \n", auth_id)
        else
          printf("\nAuthor %d affilition parse as single \n", auth_id)
        end
        puts "\n************************ Missing name **********************\n"
        print_affi(affi_object)
        puts name_list.name
        return false
      # problem: missing author or author_affiliation_id incorrect
    elsif affi_object.article_author_id == nil or \
       affi_object.article_author_id != auth_id
        if parsed_complex == false
          printf("\nAuthor %d affilition parsed as complex \n", auth_id)
        else
          printf("\nAuthor %d affilition parse as single \n", auth_id)
        end
        puts "\n************************ Wrong Author ID **********************\n"
        print_affi(affi_object)
        print name_list
        return false
      else
        return true
      end
    end

    # determine if an affilition string is complex by checking if it
    # contains 2 or more keywords from the common lists
    def is_complex(an_item)
      occurrence_counter = 0
      #verify if item has two or more affilition elements
      if get_institution(an_item) != nil then occurrence_counter += 1 end
      if get_country(an_item) != nil then occurrence_counter += 1 end
      if get_department(an_item) != nil then occurrence_counter += 1 end
      if get_faculty(an_item) != nil then occurrence_counter += 1 end
      if get_workgroup(an_item) != nil then occurrence_counter += 1 end
      # if more than one affilition element, treat as complex
      if occurrence_counter > 1
        return true
      else
        return(false)
      end
    end

    # determine if an affilition string is simple by checking if it fully matches
    # one of the keywords from the common lists
    def is_simple(an_item)
      #verify if item has two or more affilition elements
      found_this = get_institution(an_item)
      if found_this != nil and found_this.downcase().strip == an_item.downcase().strip then return true end
      found_this = get_department(an_item)
      if found_this != nil and found_this.downcase().strip == an_item.downcase().strip then return true end
      found_this = get_faculty(an_item)
      if found_this != nil and found_this.downcase().strip == an_item.downcase().strip then return true end
      found_this = get_workgroup(an_item)
      if found_this != nil and found_this.downcase().strip == an_item.downcase().strip then return true end
      found_this = get_country(an_item)
      if found_this != nil and found_this.downcase().strip == an_item.downcase().strip then return true end
      if found_this != nil and found_this.length > an_item.length then return true end # found a country synonym
      return false
    end

    # print the contents of the affiliation object
    def print_affi(affi_object)
      printf "\nAuthor ID: %d affiliation: %s affiliation short: %s country: %s\n", affi_object.article_author_id, affi_object.name, affi_object.short_name, affi_object.country
      printf "\nAddress: %s, %s, %s, %s, %s\n", affi_object.add_01, affi_object.add_02, affi_object.add_03,affi_object.add_04, affi_object.add_05
    end
  end
end
