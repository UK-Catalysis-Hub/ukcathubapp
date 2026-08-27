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

  def get_all_collaborators(filter)
    # Get collaborations
    collaborations = AuthorCollaboration.where(
      "(author_source = ? OR author_target = ?) AND weight > 1",
      self.id,
      self.id
    )

    # Get initil id list for nodes:
    node_ids = collaborations.flat_map do |edge|
      [edge.author_source, edge.author_target]
    end.uniq
    # Get Nodes all nodes:
    nodes = Author.where(id: node_ids).map do |author|
      { data:{
        id: author.id.to_s,
        label: "#{author.get_abreviated_name}"},
        classes: (author.id == self.id ? "central" : nil)
      }
    end
    # get primary edges
    edges = collaborations.map do |edge|
      { data:
        {
          source: edge.author_source.to_s,
          target: edge.author_target.to_s,
          weight: edge.weight,
          is_secondary: false
        }
      }
    end
    seen_pairs = Set.new
    collaborations.each do |one_coll|
      seen_pairs.add([one_coll.author_source, one_coll.author_target])
    end
    # get secondary edges
    secondary_edges = AuthorCollaboration.where(
      author_source: node_ids,
      author_target: node_ids
    )

    secondary_edges.each do |an_edge|
      if an_edge.weight > 1 # if one is through this coauthorship
        pair = [an_edge.author_source, an_edge.author_target].sort
        next if seen_pairs.include?(pair)
        new_edge = {data: {
            source: an_edge.author_source.to_s,
            target: an_edge.author_target.to_s,
            weight: an_edge.weight-1,
            is_secondary: true
            }
          }
        edges << new_edge
      end
    end
    nodes + edges
  end
end
