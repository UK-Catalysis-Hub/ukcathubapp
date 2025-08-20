class OrganisationParser
  def self.parse(raw_affiliation)
    # Logic to handle messy organisation strings
    {
      name: extract_name(raw_affiliation),
      country: extract_domain(raw_affiliation),
      city: extract_city(raw_affiliation),
      sector: extract_sector(raw_affiliation),
    }
  end
  def refresh_lists
    Rails.logger.info "Refreshing lists"
    @organisation_list = Organisation.group(:name).pluck(:name).compact()
    @countries_list = Affiliation.group(:country).pluck(:country).compact()
    @schools_list = Affiliation.group(:school).pluck(:school).compact()
    @departments_list = Affiliation.group(:department).pluck(:department).compact()
    @faculties_list = Affiliation.group(:faculty).pluck(:faculty).compact()
    @groups_list = Affiliation.group(:work_group).pluck(:work_group).compact()
    @cities_list = Organisation.group(:city).pluck(:city).compact()
    @country_synonyms = {
      "UK" => "United Kingdom",
      "(UK)" => "United Kingdom",
      "U.K." => "United Kingdom",
      "(U. K.)" => "United Kingdom",
      "U.K" => "United Kingdom",
      "PRC" => "Peoples Republic of China",
      "P.R.C." => "Peoples Republic of China",
      "P.R.China" => "Peoples Republic of China",
      "P.R. China" => "Peoples Republic of China",
      "P. R. China" => "Peoples Republic of China",
      "China" => "Peoples Republic of China",
      "People's Republic of China" => "Peoples Republic of China",
      "People’s Republic of China" => "Peoples Republic of China",
      "United States" => "United States of America",
      "USA"=> "United States of America",
      "US"=> "United States of America",
      "U.S.A."=> "United States of America",
      "U. S. A."=> "United States of America",
      "U.S."=> "United States of America",
      "U. S."=> "United States of America",
      "Korea"=> "South Korea",
      "Republic of Korea"=> "South Korea"
    }
    @institution_synonyms = {
      'A*STAR Agency for Science, Technology and Research' => 'Agency for Science, Technology and Research A*STAR',
      'A*STAR (Agency for Science, Technology and Research)' => 'Agency for Science, Technology and Research A*STAR',
      'ALISTORE‐ERI'=>'ALISTORE European Research Institute',
      'Agency for Science, Technology and Research' => 'Agency for Science, Technology and Research A*STAR',
      'AWE' => 'Atomic Weapons Establishment Plc',
      'AWE Public Limited Company' => 'Atomic Weapons Establishment Plc',
      'AWE plc' => 'Atomic Weapons Establishment Plc',
      'Atomic Weapons Establishment (AWE) Plc' => 'Atomic Weapons Establishment Plc',
      'Bio Nano Consulting' => 'Bio Nano Consulting Ltd',
      'Binghamton University'=>'Binghamton University, State University of New York',
      'State University of New York at Binghamton'=>'Binghamton University, State University of New York',
      'CELLS-ALBA Synchrotron Light Facility' => 'ALBA Synchrotron Light Source',
      'CELLS—ALBA Synchrotron' => 'ALBA Synchrotron Light Source',
      'CIC Energigune'=>'CIC EnergiGune',
      'Complutense University of Madrid' => 'Universidad Complutense de Madrid',
      'DGIST' => 'Daegu Gyeongbuk Institute of Science & Technology (DGIST)',
      'Daegu Gyeongbuk Institute of Science & Technology' => 'Daegu Gyeongbuk Institute of Science & Technology (DGIST)',
      'Daresbury Laboratory STFC'=>'Daresbury Laboratory',
      'STFC Daresbury Laboratory'=>'Daresbury Laboratory',
      'Defence Science Technology Laboratory (DSTL)' => 'Defence Science Technology Laboratory ',
      'Diamond Light Source' => 'Diamond Light Source Ltd.',
      'Diamond Light Source Ltd Harwell Science and Innovation Campus' => 'Diamond Light Source Ltd.',
      'Diamond Light source Ltd' => 'Diamond Light Source Ltd.',
      'ESRF' => 'European Synchrotron Radiation Facility',
      'ESRF-The European Synchrotron' => 'European Synchrotron Radiation Facility',
      'East China University of Science & Technology' => 'East China University of Science and Technology',
      'Ecole Polytechnique Fédérale de Lausanne' => 'Ecole Polytechnique Federale de Lausanne',
      'Ecole Polytechnique Fédérale de Lausanne (EPFL)' => 'Ecole Polytechnique Federale de Lausanne',
      'Elettra - Sincrotrone Trieste S.C.p.A.' => 'Elettra-Sincrotrone Trieste S.C.p.A.',
      'Elettra – Sincrotrone Trieste S.C.p.A.' => 'Elettra-Sincrotrone Trieste S.C.p.A.',
      'Elettra – Sincrotrone Trieste, S.S.' => 'Elettra-Sincrotrone Trieste S.C.p.A.',
      'Empa Materials Science and Technology' => 'Empa-Swiss Federal Laboratories for Materials Science and Technology',
      'Empa − Swiss Federal Laboratories for Materials Science and Technology' => 'Empa-Swiss Federal Laboratories for Materials Science and Technology',
      'Esfera UAB' => 'Universitat Autònoma de Barcelona',
      'ETH Zurich'=>'ETH Zürich',
      'Ecole Polytechnique Federale de Lausanne'=>'École Polytechnique Fédérale de Lausanne',
      'Federal University of Para'=>'Federal University of Pará',
      'Finden Limited' => 'Finden Ltd',
      'Flemish Institute for Technological Research' => 'Flemish Institute for Technological Research (VITO)',
      'Flemish Institute for Technological Research, VITO NV' => 'Flemish Institute for Technological Research (VITO)',
      'Friedrich-Alexander University Erlangen-Nürnberg' => 'Friedrich-Alexander-Universität Erlangen-Nürnberg',
      'Fritz Haber Institute of the Max-Planck Society' => 'Fritz-Haber-Institut der Max-Planck Gesellschaft',
      'Fritz-Haber Institute of the Max-Planck Society' => 'Fritz-Haber-Institut der Max-Planck Gesellschaft',
      'Glasgow University' => 'University of Glasgow',
      'Gdansk University of Technology'=>'Gdańsk University of Technology',
      'Harwell XPS' => 'HarwellXPS',
      'Honeywell Int.' => 'Honeywell International Incorporated',
      'Helmut-Schmidt-University, University of the Armed Forces' => 'Helmut Schmidt University - University of the Federal Armed Forces',
      'HH Wills Physics Laboratory'=>'HH Wills Physics Laboratory, University of Bristol',
      'Huazhong University of Science and Technology (HUST)'=>'Huazhong University of Science and Technology',
      'ICREA' =>"Institució Catalana de Recerca i Estudis Avançats",
      'ICREA, Institució Catalana de Recerca i Estudis Avançats'=>'Institució Catalana de Recerca i Estudis Avançats',
      'Institució Catalana de Recerca i Estudis Avançats (ICREA)'=>'Institució Catalana de Recerca i Estudis Avançats',
      'Instituto de Estructura de la Materia, CSIC'=>'Instituto de Estructura de la Materia',
      'IKERBASQUE, Basque Foundation for Science'=>'IKERBASQUE Basque Foundation for Science',
      'Ikerbasque, Basque Foundation for Science'=>'IKERBASQUE Basque Foundation for Science',
      'IMRE' => 'Institute of Materials Research and Engineering',
      'ISIS Facility' => 'ISIS Neutron and Muon Source',
      'ISIS Neutron and Muon Facility' => 'ISIS Neutron and Muon Source',
      'ISIS Pulsed Neutron and Muon Facility' => 'ISIS Neutron and Muon Source',
      'ISIS Pulsed Neutron and Muon Source' => 'ISIS Neutron and Muon Source',
      'Imperial College, London' => 'Imperial College London',
      'Institut Laue Langevin' => 'Institut Laue-Langevin',
      'Institute of Materials Research and Engineering (IMRE)' => 'Institute of Materials Research and Engineering',
      'Instituto de Ciencia de Materiales de Madrid, C.S.I.C.' => 'Instituto de Ciencia de Materiales de Madrid C.S.I.C.',
      'Instituto de Ciencia de Materiales de Madrid—CSIC' => 'Instituto de Ciencia de Materiales de Madrid C.S.I.C.',
      'International Iberian Nanotechnology Laboratory' => 'International Iberian Nanotechnology Laboratory (INL)',
      'Jawaharlal Nehru Center for Advanced Scientific Research'=>'Jawaharlal Nehru Centre for Advanced Scientific Research',
      'Johnson Matthey Technology Center' => 'Johnson Matthey Technology Centre',
      'Johnson-Matthey Technology Centre' => 'Johnson Matthey Technology Centre',
      'KAUST' => 'King Abdullah University of Science and Technology',
      'KIT' => 'Karlsruhe Institute of Technology',
      'King Abdullah University of Science and Technology (KAUST)' => 'King Abdullah University of Science and Technology',
      'Kings College London' => "King's College London",
      'King’s College London' => "King's College London",
      'Le Mans Université-CNRS'=>'Le Mans Université',
      'Ludwig‐Maximilians‐Universität München'=>'Ludwig-Maximilians Universität München',
      'Ludwig-Maximilians-Universität München'=>'Ludwig-Maximilians Universität München',
      'Ludwig‐Maximilians‐University Munich'=>'Ludwig-Maximilians Universität München',
      'Ludwig-Maximilians-University Munich'=>'Ludwig-Maximilians Universität München',
      'Ludwig‐Maximilians‐Universität'=>'Ludwig-Maximilians Universität München',
      'Ludwig-Maxilimians-Universität München'=>'Ludwig-Maximilians Universität München',
      'Ludwig Maximilians University of Munich'=>'Ludwig-Maximilians Universität München',
      'Ludwig-Maximilians-Universtität München'=>'Ludwig-Maximilians Universität München',
      'Ludwig Maximilians-Universität München 2'=>'Ludwig-Maximilians Universität München',
      'Ludwigs-Maximilians-Universität München'=>'Ludwig-Maximilians Universität München',
      'Max Planck Institute for Solid State Research' => 'Max-Planck Institute for Solid State Research',
      'National Institute for Materials Science (NIMS)'=>'National Institute for Materials Science',
      'NSG-Pilkington' => 'NSG Group',
      'NTU' => 'Nanyang Technological University',
      'New York University Abu Dhabi (NYUAD)' => 'New York University Abu Dhabi',
      'Norwegian University of Science and Technology (NTNU)' => 'Norwegian University of Science and Technology',
      'Oxford University' => 'University of Oxford',
      'PSI' => 'Paul Scherrer Institute',
      'PSL Research University'=>'Paris Sciences et Lettres Université',
      'Paris Sciences et Lettres (PSL) Université'=>'Paris Sciences et Lettres Université',
      'Pandit Deendayal Petroleum University' => 'Pandit Deendayal Energy University',
      'Paul Scherrer Institut' => 'Paul Scherrer Institute',
      'Queen Mary University London' => 'Queen Mary University of London',
      'Queens University Belfast' => "Queen's University Belfast",
      'Queen’s University Belfast' => "Queen's University Belfast",
      'Queen’s University of Belfast' => "Queen's University Belfast",
      'RAL' => 'Rutherford Appleton Laboratory',
      '(RAL)' => 'Rutherford Appleton Laboratory',
      'RCaH' => 'Research Complex at Harwell',
      'Rajamangala University of Technology ISAN (Khon Kaen Campus)'=>'Rajamangala University of Technology Isan',
      'Research Complex at Harwell (RCaH)' => 'Research Complex at Harwell',
      'Réseau sur le Stockage Electrochimique de l’Energie (RS2E)' => 'Réseau sur le Stockage Électrochimique de l’Énergie (RS2E)',
      'Sapienza University of Rome'=>'Sapienza Universitä di Roma',
      'Scienta Omicron GmbH'=>'Scienta Omicron AB',
      'Shanghai JiaoTong University'=>'Shanghai Jiao Tong University',
      'Sun Yat-sen University'=>'Sun Yat-Sen University',
      'STFC' => 'Science and Technology Facilities Council',
      'Science &amp; Technology Facilities Council' => 'Science and Technology Facilities Council',
      "SciTech" => "SciTech Daresbury",
      'Sorbonne Universités' => 'Sorbonne Université',
      'SuperSTEM' => 'SuperSTEM Laboratory',
      'SynCat@Beijing, Synfuels China Technology Co. Ltd.' => 'SynCat@Beijing Synfuels China Company Limited',
      'Synfuels China Compnay Limited' => 'SynCat@Beijing Synfuels China Company Limited',
      'Technical University Berlin' => 'Technische Universität Berlin',
      'Technion' => 'Technion - Israel Institute of Technology',
      'Technion Israel Institute of Technology' => 'Technion - Israel Institute of Technology',
      'Technion-Israel Institute of Technology' => 'Technion - Israel Institute of Technology',
      'The Abdus Salam ICTP'=> 'The Abdus Salam International Centre for Theoretical Physics',
      'The European Synchrotron' => 'European Synchrotron Radiation Facility',
      'The European Synchrotron. 71' => 'European Synchrotron Radiation Facility',
      'The Faraday Institution Quad'=>'The Faraday Institution',
      'The ISIS facility' => 'ISIS Neutron and Muon Source',
      'The UK Catalysis Hub' => 'UK Catalysis Hub',
      'The University of Liverpool' => 'University of Liverpool',
      'Tokai Carbon Co., Ltd.'=>'Tokai Carbon Co., Ltd',
      'UCL' => 'University College London',
      'UKAEA' => 'UK Atomic Energy Authority',
      'UOP LLC' => 'UOP LLC, a Honeywell Company',
      'UOP LLC, A Honeywell Company'=>'UOP LLC, a Honeywell Company',
      'Univ Rennes' => 'Université de Rennes',
      'Univ. Bordeaux' => 'Université de Bordeaux',
      'Univ. Lille' =>'Université Lille',
      'Univ Limoges' =>'Université de Limoges',
      'Univ. Pablo de Olavide' => 'Universidad Pablo de Olavide',
      'Univ. of Manchester' => 'The University of Manchester',
      'Universidade Federal de Pernambuco'=> 'Federal University of Pernambuco',
      'Universidade de São Paulo'=>'University of São Paulo',
      'Universitat Politecnica de Catalunya' => 'Universitat Politècnica de Catalunya',
      'University College of London' => 'University College London',
      'University of Aston' => 'Aston University',
      'University of Bern' => 'Universität Bern',
      'University of Berne' => 'Universität Bern',
      'University of Bologna' => 'Università di Bologna',
      'University of California Davis' => 'University of California, Davis',
      'University of Cardiff' => 'Cardiff University',
      'University of Durham' => 'Durham University',
      'University of Edinburgh' => 'The University of Edinburgh',
      'University of Manchester' => 'The University of Manchester',
      "University of New South Wales (UNSW)" => "University of New South Wales",
      'University of Padova' => 'Università di Padova',
      'University of Padua' => 'Università di Padova',
      'University of St Andrews' => 'University of St. Andrews',
      'University of Trieste' => 'Università degli Studi di Trieste',
      'Università degli Studi di Padova' => 'Università di Padova',
      'Université Claude Bernard – Lyon 1' => 'Université Claude Bernard Lyon 1',
      'Université Rennes' => 'Université de Rennes',
      'Universitat de València'=>'Universidad de Valencia',
      'University Brunei Darussalam'=>'Universiti Brunei Darussalam',
      'University Chemical Laboratory'=>'University Chemical Laboratory, Cambridge University',
      'University of Antwerpen'=>'University of Antwerp',
      'University of Padovua'=>'Università di Padova',
      'University of Shanghai for Science of Technology'=>'University of Shanghai for Science and Technology',
      'Università di Torino'=>'University of Turin',
      'Universitá di Torino'=>'University of Turin',
      'University of the Basque Country (UPV/EHU)'=>'University of the Basque Country',
      'University of the Basque Country UPV/EHU'=>'University of the Basque Country',
      'Université Paris-Saclay'=>'Université Paris Saclay',
      'Université Paris-Sud'=>'Université Paris Sud',
      'Wroclaw University of Science and Technology'=>'Wrocław University of Science and Technology',
      "UNSW" => "University of New South Wales",
      "University of New South Wales (UNSW)" => "University of New South Wales",
      'Campus UAB' =>'Universitat Autònoma de Barcelona',
      'Wrocław University of Technology' => 'Wrocław University of Science and Technology'
    }
    @hosted_institutions= { 
      "UK Catalysis Hub" => "Research Complex at Harwell",
      "HarwellXPS" => "Research Complex at Harwell",
      "Research Complex at Harwell" => "Rutherford Appleton Laboratory",
      "Rutherford Appleton Laboratory" => "Science and Technology Facilities Council",
      "ISIS Neutron and Muon Source" => "Science and Technology Facilities Council",
      "Institute of Materials Research and Engineering" => "Agency for Science, Technology and Research",
      "SuperSTEM Laboratory" => "SciTech Daresbury",
      "SciTech Daresbury" => "Science and Technology Facilities Council"
   }

    @inst_host_map= { 
      "Research Complex at Harwell"=>["UK Catalysis Hub","HarwellXPS"],
      "Rutherford Appleton Laboratory"=>["Research Complex at Harwell","ISIS Neutron and Muon Source"],
      "Science and Technology Facilities Council"=> ["Rutherford Appleton Laboratory", "Daresbury Laboratory"],
      "Agency for Science, Technology and Research" => ["Institute of Materials Research and Engineering"],
      "SciTech Daresbury" => ["SuperSTEM Laboratory"],
      "Daresbury Laboratory" => ["SciTech Daresbury"]
   }

   @country_exceptions = [
     "Denmark Hill", "UK Catalysis Hub", "UK CRG",
     "Sasol Technology U.K.", "Sasol Technology UK",
     "N. Ireland", 'Indian', 'Northern Ireland', "Australian",
     "University of New South Wales"]
        
   @country_provinces  = { "England" => "United Kingdom",
     "Scotland" => "United Kingdom",
     "Wales" => "United Kingdom",
     "Northern Ireland" => "United Kingdom",
     "N. Ireland" => "United Kingdom"
   }
  end

  def is_hosted(inst, host)
    if @hosted_institutions.key?(inst) and
       @hosted_institutions[inst] == host
      return true
    end
   false
  end
  
  # If institutions can have multiple hosts, try this version to get all paths:
  def get_host_paths(org_list)
    host_map = {}
    org_list.each do |a_affi|
      org_list.each do |b_affi|
        if is_hosted(a_affi, b_affi)
          host_map[b_affi] ||= []
          host_map[b_affi] << a_affi
        end
      end
    end
    all_paths=[]
    org_list.each do |a_affi|
      all_paths += build_partial_paths(a_affi, host_map)
    end
    # remove single paths
    ret = []
    all_paths.each do |a_path|
      if a_path.length > 1
        ret.append(a_path)
      end
    end
    # convert to set and back to array to eliminate duplicates
    ret.to_set.to_a
  end

  # try to find paths recursively
  def build_partial_paths(entity, host_map)
    # Start with the base path (just the entity itself)
    paths = [[entity]]
      hosts = host_map[entity]
      return paths unless hosts

    hosts.each do |host|
      # Recursively get all paths from this host
      host_paths = build_partial_paths(host, host_map)

      # Add the current entity to each found path
      host_paths.each do |path|
        paths << path + [entity]
      end
    end

    paths
  end

  def has_hosting_path?(start_host, target_hosted, visited = Set.new)
    return false if !@inst_host_map.keys.include?(start_host)
    return false if visited.include?(start_host)
    visited.add(start_host)

    return true if @inst_host_map[start_host].include?(target_hosted)

    @inst_host_map[start_host].each do |intermediate|
      return true if has_hosting_path?(intermediate, target_hosted, visited)
    end

    false
  end

  def build_partial_paths2(org, host_map, visited = [])
    return [] if visited.include?(org)
    visited << org
    paths = []

    if host_map[org]
      host_map[org].each do |host|
        sub_paths = build_partial_paths(host, host_map, visited.dup)
        if sub_paths.empty?
          paths << [host, org]
        else
          sub_paths.each do |sub_path|
            paths << sub_path + [org]
          end
        end
      end
    end
    paths
  end

  def get_longest_path(paths_list)
    longest_path = []
    paths_list.each do |a_path| 
      if longest_path == []
        longest_path = a_path
      elsif longest_path.length < a_path.length
        longest_path = a_path
      end
    end
    longest_path
  end


  # Check the if any of the values in the list is in the given string
  def check_list(a_string, a_list)
    return ["", ""] if a_string.nil? || a_list.nil?

    # Find all words from the list that match the string
    matching_words = a_list.select do |word|
      a_string.match?(/\b#{Regexp.escape(word)}\b/u)
    end

    # Choose the longest matching word
    longest_match = matching_words.max_by(&:length)

    # Remove the longest match from the original string
    if !longest_match.nil? and !longest_match.empty?
      cleaned_string = a_string.gsub(/\b#{Regexp.escape(longest_match)}\b/ui, "")
    else
       longest_match = ""
       cleaned_string = a_string
    end
    [longest_match, cleaned_string]
  end

  # verify if the string has some of the synomyms in the provided synonym table
  def str_has_synonym_old(affi_str, synonym_dict)
    affi_str = affi_str.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    temp_str = synonym_dict.keys
      .map { |k| k.encode('UTF-8', invalid: :replace, undef: :replace, replace: '') }
      .select { |k| affi_str.include?(k) }
      .max_by(&:length)

    ret_str = temp_str ? synonym_dict[temp_str] : ""
    affi_str = temp_str ? affi_str.sub(temp_str, '') : affi_str
    [ret_str, affi_str]
  end

  # verify if the string has some of the synomyms in the provided synonym table
  def str_has_synonym(affi_str, synonym_dict)
    # this removes invalid UTF-8)
    affi_str = affi_str.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')

    # Sort synonyms by length descending
    sorted_keys = synonym_dict.keys
      .map { |k| k.encode('UTF-8', invalid: :replace, undef: :replace, replace: '') }
      .sort_by { |k| -k.length }

    # this uses a regular expression to find a match and removes trailing commas and spaces
    matched_key = sorted_keys.find do |k|
      #affi_str.match?(/\b#{Regexp.escape(k)}\b[, ]*?/i)
      affi_str.match?(Regexp.new(Regexp.escape(k)))
    end

    # this returns the value for the matched key or blank if no matched key
    ret_str = matched_key ? synonym_dict[matched_key] : ""

    # remove the matched key and clean the remainder of the affi string
    if matched_key
      # Remove synonym and trailing punctuation/space
      #affi_str.gsub!(/\b#{Regexp.escape(matched_key)}\b[, ]*?/i, '')
      affi_str.gsub!(Regexp.new(Regexp.escape(matched_key) + '[, ]*?'), '')
      affi_str.strip!
    end
    #returns the matched value (or "") and the resulting affi string
    [ret_str, affi_str]
  end

  def remove_extra_commas(str)
    str.gsub(/, ,|; ;/, '')
       .gsub(/ \,/, ',')
       .gsub(/ \;/, ';')
       .strip
       .then { |s| s[-1]&.match?(/\w/) ? s : s[0...-1] }
       .then { |s| s.size <= 1 ? '' : s[s.index(s[/\w/])..].strip }
   #str.gsub(/[[:punct:]]+\s*|\s+[[:punct:]]+/, ' ').strip.squeeze(' ')
  end

  def get_country_synonyms
    return @country_synonyms
  end

  def get_institution_synonyms
    return @institution_synonyms
  end

  def get_organisations
    return @organisation_list
  end

  def get_organisation_synonyms
    return @institution_synonyms
  end
  
  def get_institutions_in_str(str, synonym_dict, institution_list)
    institution, remainder = str_has_synonym(str, synonym_dict)
    #puts "inst: #{institution}"
    #puts "rem: #{remainder}"
    if institution.to_s.empty?
       institution, remainder = check_list(str, institution_list)
    end

    if institution.to_s.empty?
      non_inst = remove_extra_commas(remainder.strip)
      return ["", non_inst]
    else
      result = get_institutions_in_str(remainder.strip, synonym_dict, institution_list)
      # If result starts with "", remove it
      #puts "result #{result}"
      result.shift if result.first == ""
      return [institution] + result
    end
  end

  # verify if the string contains country exceptions
  def has_country_exception(a_str)
    has_exceptions = false
    @country_exceptions.each do |an_exception|
      if a_str.include?(an_exception)
        has_exceptions =  true
      end
    end
    has_exceptions
  end

  def handle_country_exception(cr_string)
    a_country_exception, reminder_e = check_list(cr_string, @country_exceptions)
    return ['', cr_string] if a_country_exception.nil?

    # Reinsert exception in the original location
    exception_at = cr_string.index(a_country_exception)
    parsed_country, parsed_reminder = parse_countries(reminder_e)

    if exception_at && exception_at < parsed_reminder.length
      updated_reminder = parsed_reminder[0...exception_at] + a_country_exception + parsed_reminder[exception_at..]
    else
      updated_reminder = parsed_reminder + " " + a_country_exception
    end

    [parsed_country, updated_reminder.strip]
  end

  def parse_countries(a_str)
    # Handle country exceptions
    if has_country_exception(a_str)
      exception_name, cleaned_str = handle_country_exception(a_str)
      return [exception_name, cleaned_str] unless exception_name.empty?
    end

    # Check synonym vs country name
    synonym_name, reminder_s = str_has_synonym(a_str, @country_synonyms)
    country_name, reminder_c = check_list(a_str, @countries_list)
    province_name, reminder_p = str_has_synonym(a_str, @country_provinces)

    if province_name != ''
      return [province_name, reminder_p]
    elsif country_name != ''
      return [country_name, reminder_c]
    elsif synonym_name != ''
      return [synonym_name, reminder_s]
    else
      return ['', a_str]
    end
  end

  def parse_institutions(affiliation_str)
    #affi_clean = replace_institution_synonyms(affiliation_str)???
    institutions_list = get_institutions_in_str(affiliation_str, @institution_synonyms, @organisation_list)
    host_paths = get_host_paths(institutions_list)
    if host_paths != []
      longest_path = get_longest_path(host_paths)
      non_inst_items = longest_path[1..] + (institutions_list.to_set - longest_path.to_set).to_a
      non_parsed = non_inst_items.join(", ") unless non_inst_items == []
      a_institution = longest_path[0]
      [a_institution, non_parsed]
    else
      institutions_list
    end
  end

  # Before parsing, institution, replace synonyms
  # and return string to parse corrected
  def replace_institution_synonyms(affiliation_str)
    strcpy = affiliation_str
    @institution_synonyms.each do |synonym, original|
      if strcpy.include?(synonym)
        strcpy.sub!(synonym, original)
      end
    end
    strcpy
  end

  def remove_partial_units(returning)
    # pairs = [["department", "Chemistry"], ["school", "School of Chemistry"]]
    unit_pairs = returning
    value_elements = unit_pairs.map {|_,second| second}
    filtered_pairs = unit_pairs.reject do |_,second|
      value_elements.any?{|other| other!= second && other.include?(second)}
    end
    filtered_pairs
  end



  # return a list of unit tuples and the unparsed rest of the string
  def parse_org_units(affiliation_str)
    units = {
      "department"  => @departments_list,
      "school"      => @schools_list,
      "work_group"  => @groups_list,
      "faculty"     => @faculties_list
    }
    found_units = []
    remainder = affiliation_str.dup
    units.each do |unit_type, unit_list|
      match = check_list(affiliation_str, unit_list)[0]
      next unless match && !match.empty?
      found_units << [unit_type, match]
      #remainder.sub!(match, '') # remove match from affiliation string
    end
    # check that the units are actual matches and not partials
    # can cause errrors in parsing
    found_units = remove_partial_units(found_units)
    found_units.each do |_, take_out|
      remainder.sub!(take_out, "")
    end

    [found_units, (remainder.nil? || remainder.empty?)? "" : remove_extra_commas(remainder.strip)]
  end

  def clean_address_string(affi_string)
    cleaned = affi_string
      .gsub(/[\r\n\u2005\u202f\t\v]/, " ")  # Remove control characters
      .gsub(/''/, "'")                      # Fix SQL apostrophes
      .gsub(/[‘’]/, "'")                    # Normalize curly apostrophes
      .gsub(/[“”]/, '"')                    # Normalize curly quotes
      .gsub("&nbsp;", " ")                  # this one is not cleaned by CGI
      .squish                               # Clean up whitespace
    cleaned = CGI.unescapeHTML(cleaned)
    CGI.unescapeHTML(cleaned)
  end

  def clean_address_and_leads(the_string)
    leading_leftovers = ["and "]
    the_string = clean_address_string(the_string)
    leading_leftovers.each do |leftover|
      if the_string.starts_with?(leftover)
        the_string.sub!(leftover, "")
      end
    end
    the_string
  end

  # split single line affiliation strings
  def split_single(affiliation_str)
    # affiliation parts missing city and province
    inst_str = dept_str = faculty_str = group_str = ctry_str = school_str = ""
    splitting_this = clean_address_string(affiliation_str)

    # get institution using institution and institution synonyms list
    inst_str, splitting_this = parse_institutions(splitting_this)
    # get organitation units as
    # [list of units, remainder]
    list_of_units, remainder = parse_org_units(splitting_this)
    list_of_units.each do |a_unit, a_value|
      case a_unit
        when 'department'
          dept_str = a_value
        when 'school'
          school_str = a_value
        when 'work_group'
          group_str = a_value
        when 'faculty'
          faculty_str = a_value
      end
    end
    splitting_this = remainder
    # lookup using Country Synonyms table
    # need to remove country exceptions first
    # should also handle region/state and city here
    ctry_str, splitting_this = parse_countries(splitting_this)
##        ctry_str, splitting_this = str_has_synonym(splitting_this, country_synonyms)
##        #  lookup using Countries list
##        if ctry_str == "":
##            ctry_str, splitting_this = check_list(splitting_this, countries_list)

    splitting_this = remove_extra_commas(splitting_this)
    splitting_this = clean_address_and_leads(splitting_this)

    return_parsed = {'institution': inst_str, 'school': school_str,
                     'department': dept_str, 'faculty': faculty_str,
                     'work_group': group_str, 'country': ctry_str,
                     'address':  splitting_this}
    # use this to eliminate empties
    # return_parsed = {k:v for k,v in return_parsed.items() if v != ''}
    return return_parsed
  end

  # should have at least an organisation, plus another field
  def is_one_liner (str_affi)
    is_single_line_affi = false
    affi_parsed = split_single(str_affi)
    affi_parsed = affi_parsed.compact_blank() 
    if affi_parsed.length > 1 and affi_parsed.keys().include?(:institution) 
      is_single_line_affi = true if affi_parsed.length > 1
    end
    is_single_line_affi
  end

  def parse_and_map_single(single_affi)
    sl_elements = split_single(single_affi[1])
    [sl_elements, [single_affi[0]]]
  end

  # this will parse cr_affis, calling split_single to help
  def parse_and_map_multiline(affi_list)
    return_parsed = []
    cr_ids =[]
    tmp_hosted = []
    parsed_affi = { }
    affi_list.each do |a_line|
      sl_elements = split_single(a_line[1])
      #puts("Parsed:  #{a_line.inspect} as:\n\t #{sl_elements.inspect}")
      # add the id to the list of parsed lines
      #puts "* Parsing: #{a_line[0]}"
      cr_ids.append(a_line[0])
      if parsed_affi == {}
        parsed_affi = sl_elements
      else
        sl_elements_no_blanks = sl_elements.compact_blank()
        #puts "* Parsed non blanks #{sl_elements_no_blanks.inspect}"
        sl_elements_no_blanks.each do |key, value|
          case key
          when :address
            #puts "adding the address #{value}, tmp_hosted #{tmp_hosted.inspect}"
            parsed_affi[:address] = [parsed_affi[:address], value].compact_blank.join(', ') if parsed_affi[:address] != value
          when :institution
            if parsed_affi[:institution].present?
              #if is_hosted(parsed_affi[:institution], value) or 
              if has_hosting_path?(parsed_affi[:institution], value) or
                 has_hosting_path?(value, parsed_affi[:institution])
                #puts "This is hosted test k: #{key} v: #{value} in #{parsed_affi[:institution]}"
                #puts "These host_paths #{get_host_paths([parsed_affi[:institution], value])}"
                #puts "is added to #{parsed_affi[:address]}"
                tmp_hosted.append(value)
                parsed_affi[:address] = [parsed_affi[:address], value].compact_blank.join(', ')
              else
                #puts "This fails is hosted test k: #{key} v: #{value} in #{parsed_affi[:institution]}"
                if !tmp_hosted.empty?
                  #parsed_affi[:address] = (tmp_hosted + parsed_affi[:address]).compact_blank.join(', ')
                  tmp_hosted = []
                end
                cr_ids.pop
                return_parsed << [parsed_affi, cr_ids]
                cr_ids = [a_line[0]]
                #puts "= will parse #{sl_elements_no_blanks}"
                parsed_affi = sl_elements_no_blanks
              end
            else
              #puts "* This is the main institution #{value}"
              parsed_affi[:institution] = value
            end
          else
            if parsed_affi[key].blank?
              parsed_affi[key] = value
            else
              #puts "* This #{key} with val: #{value} as address"
              parsed_affi[:address] = [parsed_affi[:address], value].compact_blank.join(', ') unless parsed_affi[key] == value
            end
          end
        end
      end
    end
    return_parsed << [parsed_affi, cr_ids]
    return_parsed
  end
end
