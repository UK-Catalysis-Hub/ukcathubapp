class Author < ApplicationRecord
  # relationships to articles
  has_many :article_authors
  has_many :articles, through: :article_authors

  #extra relationships to intermediate Crossref objects
  has_many :cr_affiliations, through: :article_authors
  has_many :author_affiliations, through: :article_authors

  # relationships to affiliations
  has_many :affiliations, through: :author_affiliations
  
  # scopes
  scope :isap, -> {where("authors.isap = 1")}
  scope :not_verified, -> {joins("INNER JOIN article_authors ON article_authors.author_id = authors.id").where("article_authors.status is not 'verified'") }
  scope :active, -> {joins(:articles).select("authors.id, authors.last_name ||', '|| authors.given_name as full_name, COUNT(*) AS 'pub_count', authors.orcid").where("articles.status = 'Added'").group("authors.id")}
  scope :publications_count, -> {isap.joins(:articles).select("authors.id, authors.last_name ||', '|| authors.given_name as full_name, COUNT(*) AS 'pub_count', authors.orcid").order("pub_count DESC").group("authors.given_name, authors.last_name")}
  scope :data_objects_count, -> {isap.joins(:articles).joins("INNER JOIN article_datasets ON article_datasets.article_id = articles.id").where("article_datasets.article_id = articles.id").select("authors.id, authors.last_name ||', '|| authors.given_name as full_name, COUNT(*) AS 'pub_count'").order("pub_count DESC").group("authors.given_name, authors.last_name")}
  scope :citations_count, -> {isap.joins(:articles).select("authors.id, authors.last_name ||', '|| authors.given_name as full_name, SUM(articles.referenced_by_count) AS 'Citations'").order("Citations DESC").group("authors.given_name, authors.last_name")}
  scope :country_count, -> {Author.joins(:author_affiliations).select('author_affiliations.country').group(:country).count('*')}
  def get_full
    full_n = (self.given_name == nil ? self.last_name : self.last_name + ", " +self.given_name) 
    return full_n
  end
  
  def get_abreviated_name
    pr_name = self.given_name ? self.given_name.gsub('á','a').gsub('é','e').gsub('í','i').gsub('ó','o').gsub('ú','u') : ""
    pr_name = pr_name.gsub(/\w+/){|s| "#{s[0].upcase}. "}.sub(/\w+\z/, &:capitalize).gsub(' .',' ')
    pr_name += self.last_name
    return pr_name
  end

  def get_all_collaborators(min_collab = 1, filter)
    # Get collaborations
    collaborations = AuthorCollaboration.where(
      "(author_source = ? OR author_target = ?) AND weight > ?",
      self.id,
      self.id,
      min_collab
    )

    # Get initial id list for nodes:
    node_ids = collaborations.pluck(:author_source, :author_target).flatten.uniq

    puts "*"*80
    #puts "Nodes before pluck: #{node_ids.length}"
    if filter
      node_ids = Author.isap.where(id: node_ids).pluck(:id)
    end
    #puts "Nodes after pluck: #{node_ids.length}"
    #puts "*"*80
    # Get Nodes all nodes:
    nodes = Author.where(id: node_ids).map do |author|
      #next if filter and author.isap
      { data:{
          id: author.id.to_s,
          label: author.get_abreviated_name,
          active: author.isap,
          full_name: author.get_full,
          orcid: author.orcid,
          pub_count: author.articles.count()
        },
        classes: (author.id == self.id ? "central" : nil)
      }
    end
    active_ids = node_ids.to_set 
    # get primary edges
    edges = collaborations.filter_map do |edge|
      next unless active_ids.include?(edge.author_source)
      next unless active_ids.include?(edge.author_target)
      { data:
        {
          source: edge.author_source.to_s,
          target: edge.author_target.to_s,
          weight: edge.weight,
          is_secondary: false
        }
      }
    end

    seen_pairs = collaborations.each_with_object(Set.new) do |edge, edge_set|
      edge_set << [edge.author_source, edge.author_target].sort
    end

    # get secondary edges
    AuthorCollaboration
      .where(author_source: node_ids, author_target: node_ids)
      .where("weight>?", min_collab)
      .each do |an_edge|
      pair = [an_edge.author_source, an_edge.author_target].sort
      next if seen_pairs.include?(pair)

      edges << {
        data: {
          source: an_edge.author_source.to_s,
          target: an_edge.author_target.to_s,
          weight: an_edge.weight,
          is_secondary: true
        }
      }
    end
    #puts nodes
    #puts edges
    nodes + edges
    
  end
  def get_all_collaborators_fix(min_collab = 1, filter=false)
    # ==========================================================
    # STEP 1: Get all direct collaborations for this author
    # ==========================================================
    #
    # Includes collaborations where the current author appears
    # either as source or target.
    #
    collaborations = AuthorCollaboration.where(
      "(author_source = ? OR author_target = ?) AND weight >= ?",
      id,
      id,
      min_collab
    )

    puts "=" * 80
    puts "AUTHOR #{id}"
    puts "Primary collaborations: #{collaborations.count}"
    puts collaborations.pluck(:author_source, :author_target, :weight)
    puts "=" * 80


    # ==========================================================
    # STEP 2: Build the set of node ids
    # ==========================================================
    #
    # Extract all author ids appearing in those collaborations.
    #
    node_ids = collaborations
                 .pluck(:author_source, :author_target)
                 .flatten
                 .uniq

    # Always include the central author.
    #
    # This prevents the graph from becoming empty if:
    #   - the author has no collaborators
    #   - collaborators are filtered out
    #
    node_ids << id
    node_ids.uniq!
    puts "=" * 80
    puts "Node ids before filter: #{node_ids.size}"
    puts "=" * 80
    # ==========================================================
    # STEP 3: Optionally filter to ISAP authors
    # ==========================================================
    #
    # If filtering is enabled:
    #   - keep only ISAP authors
    #   - ALWAYS keep the central author
    #
    if filter
      visible_ids = Author.isap.where(id: node_ids).pluck(:id)

      visible_ids << id
      visible_ids.uniq!

      node_ids = visible_ids
    end
    puts "=" * 80
    puts "Node ids after filter: #{node_ids.size}"
    puts node_ids.inspect
    puts "Contains self? #{node_ids.include?(id)}"
    puts "=" * 80
    # Fast lookup structure for edge filtering.
    active_ids = node_ids.to_set

    # ==========================================================
    # STEP 4: Build Cytoscape nodes
    # ==========================================================
    #
    authors = Author.where(id: node_ids)

    nodes = authors.map do |author|
      {
        data: {
          id: author.id.to_s,
          label: author.get_abreviated_name,
          active: author.isap,
          full_name: author.get_full,
          orcid: author.orcid,
          pub_count: author.articles.count
        },

        # Highlight the selected author
        classes: (author.id == id ? "central" : nil)
      }
    end

    # ==========================================================
    # STEP 5: Build primary edges
    # ==========================================================
    #
    # Primary edges are the collaborations directly attached
    # to the current author.
    #
    edges = []

    # Used later to avoid duplicate edges.
    #
    # We store pairs in sorted form:
    #   [2,5]
    # instead of:
    #   [5,2]
    #
    # so we can treat collaborations as undirected.
    #
    seen_pairs = Set.new

    collaborations.each do |collaboration|

      source = collaboration.author_source
      target = collaboration.author_target

      # Skip if either endpoint was removed by filtering.
      next unless active_ids.include?(source)
      next unless active_ids.include?(target)

      pair = [source, target].sort

      seen_pairs << pair

      edges << {
        data: {
          source: source.to_s,
          target: target.to_s,
          weight: collaboration.weight,
          is_secondary: false
        }
      }
    end
   
    # ==========================================================
    # STEP 6: Build secondary edges
    # ==========================================================
    #
    # These are collaborations between visible nodes that are
    # not necessarily connected directly to the central author.
    #
    AuthorCollaboration
      .where(author_source: node_ids)
      .where(author_target: node_ids)
      .where("weight >= ?", min_collab)
      .each do |collaboration|

        source = collaboration.author_source
        target = collaboration.author_target

        pair = [source, target].sort

        # Skip if already added as a primary edge.
        next if seen_pairs.include?(pair)

        seen_pairs << pair

        edges << {
          data: {
            source: source.to_s,
            target: target.to_s,
            weight: collaboration.weight,
            is_secondary: true
          }
        }
      end

    # ==========================================================
    # STEP 7: Return Cytoscape data
    # ==========================================================
    #
    # Cytoscape expects a flat array containing both nodes and
    # edges.
    #
    nodes + edges
  end
end
