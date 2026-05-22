module ArticlesHelper
  def add_article_by_doi(p_doi="",p_themes =[])
    @art = Article.find_by(doi: p_doi)
    if @art == nil
      @art = Article.new(:doi => p_doi)
      getPubData(@art, @art.doi)
      if @art.container_title == nil
        @art.container_title = "NA"
      end
      can_add_it = 0
      if @art.pub_year != nil
        # its a preprint do not add
        Rails.logger.info "Can add DOI: #{p_doi} it isn't a preprint #{@art.pub_year}"
        can_add_it = 1
      else
        Rails.logger.info "Can not add DOI: #{p_doi} it is a preprint"
      end
      if can_add_it
        @art.save()
        p_themes.each do |theme_id|
          full_theme = Theme.find(theme_id)
          article_theme = ArticleTheme.new()
          article_theme.doi = @art.doi
          article_theme.theme_id = theme_id
          article_theme.project_year = @art.pub_year
          article_theme.article_id = @art.id
          article_theme.phase = full_theme.phase
          article_theme.save()
        end
      end  
    else
      Rails.logger.info "DOI Alredy in DB: #{p_doi} themes #{p_themes.to_s()}"
    end
  end

  def getPubData(db_article, doi_text)
    puts "%"*90
    puts "Getting pub data"
    puts "%"*90
    if doi_text != ""
      # need to raise an exeption if doi is incorrect or no data is returned
      # need to check the doi is not in DB before saving (lower and uppercase versions)
      # need to trim dois before saving
      data_mappings = getPubDataXRef(doi_text) 
      # remove id, and timestamps from mappings before updating
      just_article_vals = data_mappings[0]
       # mark incomplete as it is missing authors, affiliation and themes
      just_article_vals['status'] = "Incomplete"
      just_article_vals.compact!() 
      db_article.update(just_article_vals)
      puts ("%"*80)
      puts("Added "+ db_article.doi)
      puts ("%"*80)
      # now add authors and affiliations
      addPubAuthors(data_mappings[1], data_mappings[2], db_article)
    end
    return db_article
  end

  def getPubDataXRef(doi_text)
    pub_data = XrefClient.getCRData(doi_text)
    data_mappings = XrefClient::ObjectMapper.map_xref_to_cdi(pub_data)
    return data_mappings   
  end
  
  def addPubAuthors(pub_authors,pub_auth_affis, a_pub)
    pub_authors.each do |an_author|
      temp_id = an_author["author_order"]
      an_author["doi"] =  a_pub.doi
      an_author["article_id"] =  a_pub.id
      
      new_art_author = ArticleAuthor.new(an_author)
      
      #print_author(new_art_author)
      
      # check if the article author is in the researchers table
      found_id = get_researcher_match(new_art_author)
      if found_id != 0 then
        an_author["author_id"] = found_id
        an_author["status"] = "verified"
      else
        # create a new researcher (author)
        new_researcher = Author.new(given_name: new_art_author.given_name, last_name: new_art_author.last_name, orcid: new_art_author.orcid)
        if new_researcher.save then
          an_author["author_id"] = new_researcher.id
        end
      end
      
      an_author.compact!()
      
      new_art_author.update!(an_author)
      puts "8"*90
      puts "New article author saved with id: " + new_art_author.id.to_s
      puts "New article author assigned researcher id: " + new_art_author.author_id.to_s
      puts "New article author assigned article id: " + new_art_author.article_id.to_s
      puts "8"*90
      
      # Affiliations not parsed just adding CrAffiliations for later
      pub_auth_affis.each do |affi_line|
        if affi_line["article_author_id"] == temp_id
          affi_line["article_author_id"] = new_art_author.id
          affi_line.compact!()
          new_cr_affi = CrAffiliation.new(affi_line)
          new_cr_affi.save
          puts "8"*90
          puts "Address Line: " + affi_line["name"]
          puts "8"*90
        end
      end
    end
  end
  
  def get_researcher_match(new_author)
    # Before save get best author match
    authors_list = new_author.get_similar()
    found_id = 0
    # If orcid matches or exact name match, no further verification needed
    authors_list.each { |researcher|
      if new_author.orcid !=nil and  researcher.orcid != nil \
         and researcher.orcid == new_author.orcid
         found_id = researcher.id
         break
      elsif new_author.given_name == researcher.given_name and \
        new_author.last_name == researcher.last_name
        found_id = researcher.id
        break
      end
    }
    return found_id
  end

  def get_authors_short_list(an_article)
    authors_list = an_article.article_authors[0..2]
    ret_list =""
    for auth in authors_list
      if auth.author.given_name != nil
        pr_name = auth.author.given_name.gsub('á','a').gsub('é','e').gsub('í','i').gsub('ó','o').gsub('ú','u')
        pr_name = pr_name.gsub(/\w+/){|s| "#{s[0].upcase}. "}.sub(/\w+\z/, &:capitalize).gsub(' .',' ')
        pr_name += auth.author.last_name
        this_name = pr_name
        if auth.author.isap == true
	  this_name = link_to(pr_name, auth.author)
        end
        if ret_list =="" then
	  ret_list = this_name
        else
          ret_list += ', '.html_safe + this_name
        end
      end
    end
    if an_article.article_authors.count > 3
      ret_list += ', et.al'.html_safe
    end
    ret_list
  end

  def get_authors_full_list(an_article)
    authors_list = an_article.article_authors
    ret_list =""
    for auth in authors_list
      if auth.author.given_name != nil
        pr_name = auth.author.given_name.gsub('á','a').gsub('é','e').gsub('í','i').gsub('ó','o').gsub('ú','u')
        pr_name = pr_name.gsub(/\w+/){|s| "#{s[0].upcase}. "}.sub(/\w+\z/, &:capitalize).gsub(' .',' ')
        pr_name += auth.author.last_name
        this_name = pr_name
        if auth.author.isap == true
	  this_name = link_to(pr_name, auth.author)
        end
        if ret_list =="" then
	  ret_list = this_name
        else
          ret_list += ', '.html_safe + this_name
        end
      end
    end
    ret_list
  end

  def get_themes_list(an_article)
    theme_links = an_article.article_themes.all
    disp_themes = ""
    for theme_lnk in theme_links
      theme_name = theme_lnk.theme.short
      theme_string = theme_lnk.theme.short
      if disp_themes =="" then
        disp_themes = link_to(theme_string, theme_lnk.theme)
      else
        disp_themes += ', '.html_safe + link_to(theme_string, theme_lnk.theme)
      end
    end
    disp_themes
  end
<<<<<<< HEAD

  def get_pubs_yearly_counts
    year_series = []
    arts_by_year = Article.where(:status => "Added").group(:pub_year).order(:pub_year).count
    year_series[0] = {name:"Annual", data: arts_by_year}
    sum = 0
    year_series[1] = {name:"Accumulating", data: arts_by_year.each.collect{ |aby| [aby[0], sum+=aby[1]] } }
    year_series
  end

  def get_pubs_yearly_averages
    year_series = get_pubs_yearly_counts
    min_year = Article.minimum(:pub_year)
    year_series[1][:data].each {|dtp| (dtp[1] = dtp[1]/(dtp[0]-min_year+1))}
    year_series[1][:name] = "Acc. Avg."
    year_series
  end

  def get_publisher_stats
    group_labels = ["1-5","6-10", "11-15", "16-20", "more than 20"]
    p_pub_stats = {}
    p_pub_data = {}
    p_sum = 0
    Article.publisher_count.reorder(p_count: :asc).each {|apc|
      p_sum += apc.p_count
      idx = ((apc.p_count-1)/5).to_i
      idx > 3 ? idx = 4 : idx
      p_pub_stats.include?(idx) ? p_pub_stats[idx] += 1 : p_pub_stats[idx] = 1
    }
    p_pub_data = {}
    p_pub_stats.each { |pps|
      p_pub_data[group_labels[pps[0]]] = pps[1]
    }
    [p_pub_stats, p_sum, p_pub_data, group_labels]
  end

  def get_journal_stats
    group_labels = ["1-5","6-10", "11-15", "16-20", "more than 20"]
    j_pub_stats = {}
    j_pub_data = {}
    j_sum = 0
    Article.journals_count.reorder(j_count: :asc).each {|ajc|
      j_sum += ajc.j_count
      idx = ((ajc.j_count-1)/5).to_i
      idx > 3 ? idx = 4 : idx
      j_pub_stats.include?(idx) ? j_pub_stats[idx] += 1 : j_pub_stats[idx] = 1
    }
    j_pub_data = {}
    j_pub_stats.each { |aps|
      j_pub_data[group_labels[aps[0]]] = aps[1]
    }
    [j_pub_stats,j_sum, j_pub_data, group_labels]
  end
  def get_h_index
    h_index = 0
    just_refs = Article.select(:referenced_by_count).order(:referenced_by_count=>:desc)
    just_refs.each_with_index do |item, index| 
      if item.referenced_by_count < index
        h_index =  index
=======
  
  def get_h_index
    h_index = 0
    just_refs = Article.select(:referenced_by_count).order(:referenced_by_count=>:desc)
    just_refs.each_with_index do |item, index|
      if item.referenced_by_count < index
        h_index = index-1
>>>>>>> origin/rewrite
        break
      end
    end
    h_index
  end

  def get_i10_index
<<<<<<< HEAD
    Article.where("referenced_by_count >= 10").count
  end
=======
    Article.where("referenced_by_count>=10").count 
  end  
>>>>>>> origin/rewrite
end
