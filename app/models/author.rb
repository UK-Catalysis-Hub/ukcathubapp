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
      .where("weight>1")
      .each do |an_edge|
      pair = [an_edge.author_source, an_edge.author_target].sort
      next if seen_pairs.include?(pair)

      edges << {
        data: {
          source: an_edge.author_source.to_s,
          target: an_edge.author_target.to_s,
          weight: an_edge.weight-1,
          is_secondary: true
        }
      }
    end
    #puts nodes
    #puts edges
    nodes + edges
    
  end
end
