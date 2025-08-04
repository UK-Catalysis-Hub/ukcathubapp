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
    @institutions_list = Affiliation.group(:institution).pluck(:institution)
    @countries_list = Affiliation.group(:country).pluck(:country)
    @schools_list = Affiliation.group(:school).pluck(:school)
    @departments_list = Affiliation.group(:department).pluck(:department)
    @faculties_list = Affiliation.group(:faculty).pluck(:faculty)
    @cities_list = Organisation.group(:city).pluck(:city)
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
      'A*STAR' => 'Agency for Science, Technology and Research',
      'A*STAR Agency for Science, Technology and Research' => 'Agency for Science, Technology and Research',
      'AWE' => 'Atomic Weapons Establishment Plc',
      'AWE Public Limited Company' => 'Atomic Weapons Establishment Plc',
      'AWE plc' => 'Atomic Weapons Establishment Plc',
      'Atomic Weapons Establishment (AWE) Plc' => 'Atomic Weapons Establishment Plc',
      'Bio Nano Consulting' => 'Bio Nano Consulting Ltd',
      'CELLS-ALBA Synchrotron Light Facility' => 'ALBA Synchrotron Light Source',
      'CELLS—ALBA Synchrotron' => 'ALBA Synchrotron Light Source',
      'Complutense University of Madrid' => 'Universidad Complutense de Madrid',
      'DGIST' => 'Daegu Gyeongbuk Institute of Science & Technology (DGIST)',
      'Daegu Gyeongbuk Institute of Science & Technology' => 'Daegu Gyeongbuk Institute of Science & Technology (DGIST)',
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
      'Finden Limited' => 'Finden Ltd',
      'Flemish Institute for Technological Research' => 'Flemish Institute for Technological Research (VITO)',
      'Flemish Institute for Technological Research, VITO NV' => 'Flemish Institute for Technological Research (VITO)',
      'Friedrich-Alexander University Erlangen-Nürnberg' => 'Friedrich-Alexander-Universität Erlangen-Nürnberg',
      'Fritz Haber Institute of the Max-Planck Society' => 'Fritz-Haber-Institut der Max-Planck Gesellschaft',
      'Fritz-Haber Institute of the Max-Planck Society' => 'Fritz-Haber-Institut der Max-Planck Gesellschaft',
      'Glasgow University' => 'University of Glasgow',
      'Harwell XPS' => 'HarwellXPS',
      'Honeywell Int.' => 'Honeywell International Incorporated',
      'Helmut-Schmidt-University, University of the Armed Forces' => 'Helmut Schmidt University - University of the Federal Armed Forces',
      'ICREA' =>"Institució Catalana de Recerca i Estudis Avançats",
      'IMRE' => 'Institute of Materials Research and Engineering',
      'ISIS Facility' => 'ISIS Neutron and Muon Source',
      'ISIS Neutron and Muon Facility' => 'ISIS Neutron and Muon Source',
      'ISIS Pulsed Neutron and Muon Facility' => 'ISIS Neutron and Muon Source',
      'ISIS Pulsed Neutron and Muon Source' => 'ISIS Neutron and Muon Source',
      'Imperial College, London' => 'Imperial College London',
      'Imperial College' => 'Imperial College London',
      'Institut Laue Langevin' => 'Institut Laue-Langevin',
      'Institute of Materials Research and Engineering (IMRE)' => 'Institute of Materials Research and Engineering',
      'Instituto de Ciencia de Materiales de Madrid, C.S.I.C.' => 'Instituto de Ciencia de Materiales de Madrid C.S.I.C.',
      'Instituto de Ciencia de Materiales de Madrid—CSIC' => 'Instituto de Ciencia de Materiales de Madrid C.S.I.C.',
      'International Iberian Nanotechnology Laboratory' => 'International Iberian Nanotechnology Laboratory (INL)',
      'Johnson Matthey Technology Center' => 'Johnson Matthey Technology Centre',
      'Johnson-Matthey Technology Centre' => 'Johnson Matthey Technology Centre',
      'KAUST' => 'King Abdullah University of Science and Technology',
      'KIT' => 'Karlsruhe Institute of Technology',
      'King Abdullah University of Science and Technology (KAUST)' => 'King Abdullah University of Science and Technology',
      'Kings College London' => "King's College London",
      'King’s College London' => "King's College London",
      'Max Planck Institute for Solid State Research' => 'Max-Planck Institute for Solid State Research',
      'NSG-Pilkington' => 'NSG Group',
      'NTU' => 'Nanyang Technological University',
      'New York University Abu Dhabi (NYUAD)' => 'New York University Abu Dhabi',
      'Norwegian University of Science and Technology (NTNU)' => 'Norwegian University of Science and Technology',
      'Oxford University' => 'University of Oxford',
      'PSI' => 'Paul Scherrer Institute',
      'Pandit Deendayal Petroleum University' => 'Pandit Deendayal Energy University',
      'Paul Scherrer Institut' => 'Paul Scherrer Institute',
      'Queen Mary University London' => 'Queen Mary University of London',
      'Queens University Belfast' => "Queen's University Belfast",
      'Queen’s University Belfast' => "Queen's University Belfast",
      'Queen’s University of Belfast' => "Queen's University Belfast",
      'RCaH' => 'Research Complex at Harwell',
      'Research Complex at Harwell (RCaH)' => 'Research Complex at Harwell',
      'Réseau sur le Stockage Electrochimique de l’Energie (RS2E)' => 'Réseau sur le Stockage Électrochimique de l’Énergie (RS2E)',
      'STFC' => 'Science and Technology Facilities Council',
      'Science &amp; Technology Facilities Council' => 'Science and Technology Facilities Council',
      "SciTech": "SciTech Daresbury",
      'Sorbonne Universités' => 'Sorbonne Université',
      'SuperSTEM' => 'SuperSTEM Laboratory',
      'SynCat@Beijing, Synfuels China Technology Co. Ltd.' => 'SynCat@Beijing Synfuels China Company Limited',
      'Synfuels China Compnay Limited' => 'SynCat@Beijing Synfuels China Company Limited',
      'Technical University Berlin' => 'Technische Universität Berlin',
      'Technion' => 'Technion - Israel Institute of Technology',
      'Technion Israel Institute of Technology' => 'Technion - Israel Institute of Technology',
      'Technion-Israel Institute of Technology' => 'Technion - Israel Institute of Technology',
      'The European Synchrotron' => 'European Synchrotron Radiation Facility',
      'The European Synchrotron. 71' => 'European Synchrotron Radiation Facility',
      'The ISIS facility' => 'ISIS Neutron and Muon Source',
      'The UK Catalysis Hub' => 'UK Catalysis Hub',
      'The University of Liverpool' => 'University of Liverpool',
      'UCL' => 'University College London',
      'UKAEA' => 'UK Atomic Energy Authority',
      'UOP LLC' => 'UOP LLC, A Honeywell Company',
      'Univ Rennes' => 'Université de Rennes',
      'Univ. Bordeaux' => 'Université de Bordeaux',
      'Univ. Lille' =>'Université Lille',
      'Univ Limoges' =>'Université de Limoges',
      'Univ. Pablo de Olavide' => 'Universidad Pablo de Olavide',
      'Univ. of Manchester' => 'The University of Manchester',
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
      'University of Padova' => 'Università di Padova',
      'University of Padua' => 'Università di Padova',
      'University of St Andrews' => 'University of St. Andrews',
      'University of Trieste' => 'Università degli Studi di Trieste',
      'Università degli Studi di Padova' => 'Università di Padova',
      'Université Claude Bernard – Lyon 1' => 'Université Claude Bernard Lyon 1',
      'Université Rennes' => 'Université de Rennes',
      'Campus UAB' =>'Universitat Autònoma de Barcelona',
      'Wrocław University of Technology' => 'Wrocław University of Science and Technology'
    }
    @hosted_institutions= { 
      "UK Catalysis Hub" => "Research Complex at Harwell",
      "HarwellXPS" => "Research Complex at Harwell",
      "Research Complex at Harwell" => "Rutherford Appleton Laboratory",
      "ISIS Neutron and Muon Source" => "Science and Technology Facilities Council",      
      "Institute of Materials Research and Engineering" => "Agency for Science, Technology and Research",
      "SuperSTEM Laboratory" => "SciTech Daresbury",
      "SciTech Daresbury" => "Science and Technology Facilities Council"
   }

   @country_exceptions = [
     "Denmark Hill", "UK Catalysis Hub", "UK CRG",
     "Sasol Technology U.K.", "Sasol Technology UK",
     "N. Ireland", 'Indian', 'Northern Ireland', "Australian"]
        
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
    return_str = ""
    temp_str = ""
    a_list.each do |an_item|
      if an_item in a_string
        if an_item.length > temp_str.length
          temp_str = an_item
        end
      end
    end
    if temp_str.length > 0
      a_string = a_string.sub(temp_str,"")
      return_str = temp_str
    end
    [return_str, a_string]
  end

  def check_list2(a_string, a_list)
    return_str = ""
    temp_str = ""
    
    a_list.each do |item|
      # Create a regex that matches whole word only
      regex = /\b#{Regexp.escape(item)}\b/
      if a_string.match?(regex) && item.length > temp_str.length
        temp_str = item
      end
    end

    if temp_str.length > 0
      a_string = a_string.gsub(/\b#{Regexp.escape(temp_str)}\b/, "")
      return_str = temp_str
    end

    return return_str, a_string
  end
end
