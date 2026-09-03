require 'matrix'
require 'set'

class AuthorDisambiguationService
  def initialize
    @co_occurrence = Hash.new { |h, k| h[k] = Hash.new(0) }
    @name_variants = Hash.new { |h, k| h[k] = Set.new }
  end

  def get_db_entities
   sql_query =
      "SELECT
         authors.id,
         trim(coalesce(authors.given_name, '') || ' ' || authors.last_name) AS auth_name,
         trim(coalesce(article_authors.given_name, '') || ' ' || article_authors.last_name) AS auth_variant, 
         count(*) AS occurrences
         FROM authors
             INNER JOIN article_authors ON article_authors.author_id = authors.id
         GROUP BY authors.given_name, authors.last_name, article_authors.given_name, article_authors.last_name
             ORDER BY authors.id;"
    results = ActiveRecord::Base.connection.exec_query(sql_query)
    entities = {}
    puts "Query results #{results.length}"
    temp_aliases = Set.new()
    current_id = 0
    current_canonical =""

    results.each do |row|
      if current_id == 0
        current_id = row["id"]
        current_canonical = row["auth_name"]
        temp_aliases.add(row["auth_variant"])
      elsif current_id != row["id"]
        puts "#{current_canonical} #{temp_aliases.length}"
        # add aliases set
        entities[current_id] = {
            canonical: current_canonical,
            variants: temp_aliases.to_a.sort,
            collaborators: []}
        temp_aliases = Set.new()
        current_id = row["id"]
        current_canonical = row["auth_name"]
        temp_aliases.add(row["auth_variant"])
      else
        temp_aliases.add(row["auth_variant"])
      end
    end
    # save final entity
    if current_id
      temp_aliases.add(current_canonical)
      entities[current_id] = {
        canonical: current_canonical,
        variants: temp_aliases.to_a.sort,
        collaborators: []
      }
    end

    entities
  end

  def get_collaborations
    sql_query =
      "SELECT 
         author_source AS author_id, 
         GROUP_CONCAT('[' || author_target || ', ' || weight || ']', ', ') AS colls_list
         FROM (SELECT 
            a1.author_id as author_source, a2.author_id as author_target, 
            count(*) AS weight
            FROM
               article_authors a1 JOIN article_authors a2
               ON a1.article_id = a2.article_id
               AND a1.author_id <> a2.author_id
          GROUP BY
            a1.author_id,
            a2.author_id)
       GROUP BY author_source;"
    auth_collaborations = {}
    results = ActiveRecord::Base.connection.exec_query(sql_query)
    puts results[0]
    results.each do |row|
      auth_collaborations[row['author_id']] = JSON.parse("[#{row['colls_list']}]")
    end
  end

  # add edge to graph
  # for variants need to add an edge 
  # linking variant names so they can cluster
  def add_co_occurrence(name1, name2, weight = 1)
    return if name1 == name2
    @co_occurrence[name1][name2] += weight
    @co_occurrence[name2][name1] += weight
    @name_variants[name1] << name1
    @name_variants[name2] << name2
  end  

  # Jaccard Similarity: statistical measure used to quantify how similar two
  # sets are.
  # It equals the ratio of the intersection size to the union size.
  # The value of Jaccard similarity ranges from zero to one, where zero
  # indicates that the sets have no elements in common and one indicates
  # that the sets are identical.
  def jaccard_similarity(name1, name2)
    neighbors1 = @co_occurrence[name1].keys.to_set
    neighbors2 = @co_occurrence[name2].keys.to_set
    return 0 if neighbors1.empty? || neighbors2.empty?
    intersection = (neighbors1 & neighbors2).size
    union = (neighbors1 | neighbors2).size
    intersection.to_f / union
  end

  def cluster_entities(threshold: 0.3)
    clusters = []
    processed = Set.new
    names = @co_occurrence.keys
    names.each do |name|
      next if processed.include?(name)
      cluster = [name]
      processed << name
      names.each do |other|
        next if processed.include?(other) || name == other
        if jaccard_similarity(name, other) >= threshold
          cluster << other
          processed << other
        end
      end
      clusters << cluster
    end
    clusters
  end
  
  # improveclustering by doing depth first on graph
  def cluster_entities_dfs(graph_threshold: 0.3,
                       string_threshold: 0.9)

    names = @co_occurrence.keys
    visited = Set.new
    clusters = []

    names.each do |start_name|
      next if visited.include?(start_name)

      cluster = []
      stack = [start_name]

      until stack.empty?
        current = stack.pop

        next if visited.include?(current)

        visited << current
        cluster << current

        names.each do |candidate|
          next if visited.include?(candidate)
          next if candidate == current

          if names_match?(
               current,
               candidate,
               graph_threshold: graph_threshold,
               string_threshold: string_threshold
             )
            stack << candidate
          end
        end
      end

      clusters << cluster
    end

    clusters
  end

  def disambiguate(name, known_entities, fallback_threshold: 0.85)
    if @co_occurrence.key?(name)
      best_entity = nil
      best_score = 0
      known_entities.each do |entity_id, variants|
        score = variants.map { |v| jaccard_similarity(name, v) }.max
        if score && score > best_score
          best_score = score
          best_entity = entity_id
        end
      end
      return best_entity if best_entity
    end
    fallback_match(name, known_entities, fallback_threshold)
  end

  # determine if two authors are the same either from their
  # neighbours or from their spellings
  #def same_author?(name1, name2)
  #  jaccard = jaccard_similarity(name1, name2)
  #  string = jaro_winkler_similarity(name1, name2)
  #  jaccard >= 0.3 || string >= 0.95
  #end


  def names_match?(name1, name2,
                   graph_threshold: 0.3,
                   string_threshold: 0.9)
      ##same_surname?(name1, name2) && 
      ##abbreviation_match?(name1, name2) &&
        (jaccard_similarity(name1, name2) >= graph_threshold &&
        jaro_winkler_similarity(name1, name2) >= string_threshold)
  end

  def same_surname?(name1, name2)
    name1.split.last.downcase == name2.split.last.downcase
  end
  
  def abbreviation_match?(name1, name2)
    parts1 = name1.gsub('.', '').split
    parts2 = name2.gsub('.', '').split

    return false if parts1.empty? || parts2.empty?

    surname1 = parts1.last.downcase
    surname2 = parts2.last.downcase

    return false unless surname1 == surname2

    parts1.first[0].downcase ==
      parts2.first[0].downcase
  end

  def build_entities(threshold: 0.3)
    cluster_entities(threshold: threshold).map do |cluster|
      canonical = cluster.max_by(&:length)
        {
          canonical: canonical,
          variants: cluster
        }
    end
  end

def build_entities(graph_threshold: 0.3,
                     string_threshold: 0.9)

    clusters = cluster_entities_dfs(
      graph_threshold: graph_threshold,
      string_threshold: string_threshold
    )

    entities = {}
    name_to_entity = {}

    #
    # Pass 1: create entities and lookup table
    #
    clusters.each_with_index do |cluster, index|
      entity_id = "entity_#{index + 1}"

      entities[entity_id] = {
        canonical: cluster.max_by(&:length),
        variants: cluster.sort,
        collaborators: []
      }

      cluster.each do |name|
        name_to_entity[name] = entity_id
      end
    end

    #
    # Pass 2: calculate collaborators at entity level
    #
    entities.each do |entity_id, entity|

      collaborator_entities = Set.new

      entity[:variants].each do |variant|
        @co_occurrence[variant].each_key do |neighbor|

          neighbor_entity = name_to_entity[neighbor]

          next if neighbor_entity.nil?
          next if neighbor_entity == entity_id

          collaborator_entities << neighbor_entity
        end
      end

      entity[:collaborators] =
        collaborator_entities.map do |collaborator_id|
          entities[collaborator_id][:canonical]
        end.sort
    end

    entities
  end

  # List all unique name strings in the graph
  def all_names
    @name_variants.keys.sort
  end

  # List all variants grouped by their canonical cluster
  def all_variants_by_cluster(threshold: 0.3)
    clusters = cluster_entities(threshold: threshold)
    clusters.map do |cluster|
      {
        canonical: cluster.first,
        variants: cluster,
        size: cluster.size
      }
    end
  end

  # Find which cluster a specific name belongs to
  def find_cluster_for(name, threshold: 0.3)
    clusters = cluster_entities(threshold: threshold)
    clusters.find { |cluster| cluster.include?(name) }
  end

  # Show all names that co-occur with a given name
  def neighbors_of(name)
    @co_occurrence[name]&.keys || []
  end

  # Show all variants (even singleton names with no co-occurrences)
  def all_variants
    @name_variants.keys
  end

  # Count total unique name strings
  def variant_count
    @name_variants.size
  end

  # Count total unique name strings
  def edge_count
    @co_occurrence.size
  end

  def load_variant_map(map, edge_weight: 3.0)
    count = 0
    map.each do |canonical, variants|
      variants.each do |variant|
        next if variant == canonical
        add_co_occurrence(canonical, variant, edge_weight)
        count += 1
        puts "#{canonical} ↔ #{variant}" if count % 100 == 0
      end
    end
    puts "Added #{count} synonym edges from variant map"
  end

  # Save to file using Marshal (fastest)
  def save_to_file(filename)
    File.open(filename, 'wb') do |file|
      Marshal.dump({
        co_occurrence: @co_occurrence.transform_values { |h| h.to_a },
        name_variants: @name_variants.transform_values { |s| s.to_a }
      }, file)
    end
    puts "Saved graph to #{filename} (#{@co_occurrence.size} nodes)"
  end

  # Load from Marshal file
  def self.load_from_file(filename)
    data = File.open(filename, 'rb') { |file| Marshal.load(file) }
    instance = new
    instance.instance_variable_set(:@co_occurrence, data[:co_occurrence].transform_values { |arr| arr.to_h })
    instance.instance_variable_set(:@name_variants, data[:name_variants].transform_values { |arr| Set.new(arr) })
    puts "Loaded graph from #{filename} (#{data[:co_occurrence].size} nodes)"
    instance
  end

  # JSON version (human-readable, cross-language)
  def save_to_json(filename)
    require 'json'
    File.write(filename, JSON.pretty_generate({
      co_occurrence: @co_occurrence.transform_values { |h| h.to_a },
      name_variants: @name_variants.transform_values { |s| s.to_a }
    }))
    puts "Saved graph to #{filename} (#{@co_occurrence.size} nodes)"
  end

  def self.load_from_json(filename)
    require 'json'
    data = JSON.parse(File.read(filename))
    instance = new
    instance.instance_variable_set(:@co_occurrence,
      data['co_occurrence'].transform_values { |arr| arr.to_h })
    instance.instance_variable_set(:@name_variants,
      data['name_variants'].transform_values { |arr| Set.new(arr) })
    puts "Loaded graph from #{filename} (#{instance.instance_variable_get(:@co_occurrence).size} nodes)"
    instance
  end

  private

  def fallback_match(name, known_entities, threshold)
    best_match = nil
    best_score = 0
    known_entities.each do |entity_id, variants|
      variants.each do |variant|
        score = jaro_winkler_similarity(name, variant)
        if score > best_score && score >= threshold
          best_score = score
          best_match = entity_id
        end
      end
    end
    best_match
  end

  def jaro_winkler_similarity(s, t)
    # Simplified — use 'fuzzy_match' gem in production
    s.chars.zip(t.chars).count { |a, b| a == b }.to_f / [s.length, t.length].max
  end
  def normalize_name(name)
    name
      .downcase
      .gsub(/\bdr\.?\s*/, "")
      .strip
  end

  #def jaro_winkler_similarity(s, t)
  #  Amatch::JaroWinkler.new(normalize_name(s)).match(normalize_name(t))
  #end
  
end
