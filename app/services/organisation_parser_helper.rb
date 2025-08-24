class OrganisatioParserHelper
  def get_parser()
    @cr_org_parser = OrganisationParser.new()
    @cr_org_parser.refresh_lists()
  end

  def get_close_affiliation_id(parsed_affi)
    check_this = parsed_affi.compact
    check_this.delete_if { |_, v| v.nil? || v == "" }
    if check_this.keys().include?(:address)
      check_this.delete(:address)
    end  
    affi_found = Affiliation.where(check_this)
    affi_found
  end

  def make_author_affi(parsed_address, art_aut_id)
    # search for clossest matching affi.
    matching_affi = get_close_affiliation_id(parsed_address)
    db_affi_id = 0
    if matching_affi.empty?
      puts "No affiliation in DB found."
    else
      puts ("A matching affiliation exists:\n\t #{matching_affi.inspect}")
      db_affi_id = matching_affi[0].id
    end
  
    # if not found or missing some data create new affi
    # build address from affi
    # get smallest unit
    smallest_unit = ""
    # Institution> Faculty > School > Department > Work_group + address + Country
    if parsed_address[:work_group].present?
      smallest_unit = parsed_address[:work_group]
    elsif parsed_address[:department].present?
      smallest_unit = parsed_address[:department]
    elsif parsed_address[:school].present?
      smallest_unit = parsed_address[:school]
    elsif parsed_address[:faculty].present?
      smallest_unit = parsed_address[:faculty]
    end
    normalised_address = {}
    normalised_address[:article_author_id] = art_aut_id

    if smallest_unit.present? 
      normalised_address[:name] = smallest_unit + ", "+  parsed_address[:institution] #'institution'
    else
      normalised_address[:name] = parsed_address[:institution]
    end
  
    normalised_address[:short_name] = parsed_address[:institution]
  
    addr_list = []
    # build address nesting units from small to big
    if  parsed_address[:department].present? and parsed_address[:department] != smallest_unit
      addr_list << parsed_address[:department]
    end
    if  parsed_address[:school].present? and parsed_address[:school] != smallest_unit
      addr_list << parsed_address[:school]
    end
    if  parsed_address[:faculty].present? and parsed_address[:faculty] != smallest_unit
      addr_list << parsed_address[:faculty]
    end
    # assign  to addr
    puts "The current address list #{addr_list.inspect}"
    reversed_units = addr_list.reverse

    # Assign each unit to add_01, add_02, etc.
    reversed_units.each_with_index do |unit, index|
      normalised_address[:"add_0#{index + 1}"] = unit
    end

    # Add the parsed address after the last unit
    if parsed_address[:address].present?
      next_index = reversed_units.length + 1
      normalised_address[:"add_0#{next_index}"] = parsed_address[:address]
    end

    # Always include country
    normalised_address[:country] = parsed_address[:country]
  
    normalised_address[:"affiliation_id"] = db_affi_id # assign closest match or new affi if non existent
    normalised_address
  end

  def manual_parse(parsed_affi)
    selected_option=""
    puts parsed_affi.inspect
    while not ["c"].include?(selected_option)
      parsed_affi.each_with_index do |kv_pair, index|
      puts "#{index}: #{kv_pair[0].to_s} = #{kv_pair[1].to_s}"   
      end
      puts "a. Get element from address" 
      #puts "b. Enter element manually"
      puts "c. End parsing"
      puts "Select 'a' or 'c'"
      selected_option = gets.chomp
      if selected_option == "a"
        element_sel = 0
        while element_sel < 1 or element_sel > 7
          print('Which element to get from Address [1-7]:')
          element_sel = gets.chomp
          if element_sel.match?(/\A-?\d+\z/)
            element_sel = element_sel.to_i
  	  puts "Valid integer: #{element_sel}"
	end
        end
        element_value = extract_manually(parsed_affi[:address])
        element_key = parsed_affi.keys[element_sel]
        puts "Assign Extracted '#{element_value}' to '#{element_key}'"
        parsed_affi[element_key] = element_value.strip
        new_address = parsed_affi[:address]
        if element_key != "address"
          new_address.gsub!(element_value, "").strip!
          parsed_affi[:address] = new_address
        end
      #elsif selected_option == "b"
      end
    end
    # before returning clean address and eliminate leading 'and '
    parsed_affi = clean_address_and_leads(parsed_affi)
    parsed_affi	
  end

  def clean_address_and_leads(parsed_affi)
    leading_leftovers = ["and "]
    parsed_affi[:address] = @cr_org_parser.clean_address_string(parsed_affi[:address])
    leading_leftovers.each do |leftover|
      if parsed_affi[:address].starts_with?(leftover)
        parsed_affi[:address].sub!(leftover, "")
      end
    end
    parsed_affi
  end

  def extract_manually(split_this)
    puts( split_this)
    decimal_str = ""
    (0..split_this.length).each do |indx|
      val = " "
      val = (indx/10).to_s if (indx % 10 == 0) 
      decimal_str += val
    end
    puts decimal_str
    unit_str = ""
    (0..split_this.length).each do |indx|
      val = (indx%10).to_s
      val = "0" if (indx % 10 == 0)
      unit_str += val
    end
    puts(unit_str)
    puts("start")
    str_start = gets.chomp.to_i
    puts("end")
    str_end = gets.chomp.to_i
    split_this[str_start..str_end]
  end

  def create_new_affiliation(parsed_affi)
    selected_option = ""
    puts "This is the parsed affiliation: "
    puts "#{parsed_affi.inspect}"
    puts "1. create as it is "
    puts "2. manual parse"
    while not ["1","2"].include?(selected_option)
      puts "Select '1','2'"
      selected_option = gets.chomp
    end
    if selected_option == "2"
      parsed_affi = manual_parse(parsed_affi)
    end
    puts "This is not working?"
    puts "The parsed affi is now: #{parsed_affi}"

    check_this = parsed_affi.compact
    check_this.delete_if { |_, v| v.nil? || v == "" }
    if check_this.keys().include?(:address)
      check_this.delete(:address)
    end
    # get organisation and sector
    org = Organisation.where("name = '#{check_this[:institution]}'")[0]
    check_this[:organisation_id] = org.id
    check_this[:sector] = org.sector
    affi_new = Affiliation.new()
    affi_new.assign_attributes(check_this)
    puts affi_new.inspect
    affi_new.save()
    affi_new
  end

  def replace_author_affi(db_affi, built_affi)
    existing_affi = AuthorAffiliation.find(db_affi[:id])
    check_this = built_affi.compact
    check_this.delete_if { |_, v| v.nil? || v == "" }
    if check_this.keys().include?(:address)
      check_this.delete(:address)
    end  
    existing_affi.update(built_affi)
  end

  def compare_affis(db_affi, built_affi)
    same_values = false
    comparable = db_affi.attributes.transform_keys(&:to_sym)
    comparable.compact!
    comparable.delete(:id)
    comparable.delete(:updated_at)
    comparable.delete(:created_at)
    puts "comparing\n\tAsign: #{comparable}\n\tBuilt: #{built_affi}"
    if built_affi == comparable
      same_values = true
    end
    same_values
  end

  #corrects assigned affiliations when parsed does not match
  def affi_corrector_process(built_affi, db_affi, parsed_affi)
    selected_option = ""
    puts "The options are: "
    puts "1. correct existing affi and update assigned"
    puts "2. create new affi and update assigned"
    puts "3. update assigned"
    puts "4. leave as it is for later"
    while not ["1","2","3","4"].include?(selected_option)
      selected_option = gets.chomp
    end
    if selected_option == "4"
      puts "No correction selected"
    elsif selected_option == "1"
      print "need to correct existing affiliation and update assigned"
    elsif selected_option == "2"
      puts "need to create new affiliation and update assigned"
      new_affi = create_new_affiliation(parsed_affi)
      puts "the new affi is #{new_affi.id}"
      built_affi[:"affiliation_id"] = new_affi.id
      corrected_affi = replace_author_affi(db_affi, built_affi)
    elsif selected_option == "3"
      puts "just update the existing affi"
      db_affi.update(built_affi)
      db_affi.save
    end
  end

  def prepare_for_saving(parsed_singles)
    parsed_singles.each do |a_single_affi| 
      if not a_single_affi[:country].present?
        a_single_affi[:country] = Organisation.where("name='#{parsed_singe[:institution]}'")[0].country
      end
    end
    parsed_singles
  end

  # verification of cr_one liners: parsed vs assigned
  def verify_one_liner(author_cr_affis, an_author)
    puts author_cr_affis.inspect
    puts "try to parse #{author_cr_affis[0].id},#{author_cr_affis[0].name}"
    parsed_single = @cr_org_parser.parse_and_map_single([author_cr_affis[0].id,author_cr_affis[0].name])
    puts "#### #{parsed_single.inspect} #####"
    # check if assigned matches parsed
    assigned_affi = AuthorAffiliation.find(author_cr_affis[0].author_affiliation_id)
    puts "The AutAffi in DB is:\n\t #{assigned_affi.inspect}"
    built_affi = make_author_affi(parsed_single[0], an_author.id)
    puts "The Affi built from parsed values \n\t #{built_affi.inspect}"
    they_match = compare_affis(assigned_affi, built_affi)
    if not they_match
      puts "there are differences between parsed and stored affi"
      affi_corrector_process(built_affi, assigned_affi, parsed_single[0])
    end
  end

  def verify_assinged()
    all_aut_pubs = ArticleAuthor.all
    all_aut_pubs.each do |an_author|
      author_cr_affis = CrAffiliation.where("article_author_id = #{an_author.id}")
      puts ("Author #{an_author.id} #{an_author.given_name} #{an_author.last_name}")
      puts "has #{author_cr_affis.length()} CR affiliation"
      if author_cr_affis.length() == 1
        # check this only one line
        puts author_cr_affis.inspect
        puts "try to parse #{author_cr_affis[0].id},#{author_cr_affis[0].name}"
        parsed_single = @cr_org_parser.parse_and_map_single([author_cr_affis[0].id,author_cr_affis[0].name])
        puts "#### #{parsed_single.inspect} #####"
        if author_cr_affis[0].author_affiliation_id != nil
          puts "Assigned #{author_cr_affis[0].author_affiliation_id}"
          # check if assigned matches parsed
          verify_one_liner(author_cr_affis, an_author)
        end
      end
      #author_cr_affis.each do |a_cr_affi|       
      #end
    end
  end

  def assign_missing
    unasigned_cr_affi = CrAffiliation.where({:author_affiliation_id=>nil}).order(:article_author_id)
    current_art_auth = 0
    acc_affis = []
    unasigned_cr_affi.each do |a_cr_affi|
      if acc_affis == []
        puts "started getting cr affis for #{a_cr_affi.article_author_id}"
        current_art_auth = a_cr_affi.article_author_id
        acc_affis << a_cr_affi
      elsif current_art_auth == a_cr_affi.article_author_id 
         puts "just adding a cr affi"
        acc_affis << a_cr_affi
      else
        # need to parse and assign these:
        puts "Will try to parse and assing these #{acc_affis.inspect}"
        puts "There are #{acc_affis.count} affiliations for #{current_art_auth}"
        # need to update current_art_auth
        current_art_auth = a_cr_affi.article_author_id
        # need to restart acc_affis
        acc_affis = [a_cr_affi]
        break
      end
    end
    puts "this is the reminder#{acc_affis.inspect}"
  end

  def assign_to_one_liners(cr_affis)
    cr_affis.each do |a_cr_affi|
      parsed_single = @cr_org_parser.parse_and_map_single([a_cr_affi.id, a_cr_affi.name])
      # See if there are affiliation matches
      puts " #{parsed_single.inspect}"
      # one liners should always have an institution.
      #   If not:
      #     - they are not one liners
      #     - there is a new synonym
      #     - there is a new organisation
      if parsed_single[0][:institution] == ""
        parsed_single = [get_blank_parsed]
        parsed_single[0][:address] = a_cr_affi.name
        parsef_single = manual_parse(parsed_single[0])
      end
      matching_affi = get_close_affiliation_id(parsed_single[0])
      if not matching_affi.empty?
        built_affi = make_author_affi(parsed_single[0], a_cr_affi.article_author_id)
        # if institution is new add it to DB organisations
        puts "** Will add this #{built_affi.inspect} and update CR_affi #{a_cr_affi.id}"
        assign_new_affi(built_affi, a_cr_affi)
      else
        puts ("A matching affiliation exists:\n\t #{matching_affi.inspect}")
        db_affi_id = matching_affi[0].id
      end
    end
  end

  def assign_missing2
    grouped_cr_affis = CrAffiliation.where(author_affiliation_id: nil)
                            .order(:article_author_id)
                            .group_by(&:article_author_id)

    grouped_cr_affis.each do |article_author_id, cr_affis|
      puts "Processing #{cr_affis.count} affiliations for author #{article_author_id}"
      # Here you'd parse and assign orders
      if all_one_liners(cr_affis)
        puts "can process all as one liners"
        # build each affi, see if there are matches,
        #  if yes, add author_affi, update cr_affi
        assign_to_one_liners(cr_affis)
        # if not: ask if further parsing, parse, add affi, add author_affi, update cr_affi
        #break 
      elsif some_one_liners(cr_affis)
        puts "cannot process all as one liners"
        puts "need manual parsing"
        # try parse and ask if add as it is or parse manual.
        #assign_to_one_liners(cr_affis)
        break
      else
        puts "cannot process all as one liners"
        break
      end
    end
  end

# Add organisations
# Add affiliations
# Comeback and add author affiliations

#irb(main):103* cr_affis.each do  |a_cr|
#irb(main):104*   parsed_res = @cr_org_parser.parse_and_map_single([a_cr.id, a_cr.name,a_cr])
#irb(main):105*   if parsed_res[0][:institution]==""
#irb(main):106*     puts "#{a_cr.id}\t #{a_cr.name}"
#irb(main):107*   end
#irb(main):108> end
#irb(main):109> puts ("finished")
end
