require 'matrix'
require 'set'

class AuthorDisambiguationService
  def initialize
    @co_occurrence = Hash.new { |h, k| h[k] = Hash.new(0) }
    @name_variants = Hash.new { |h, k| h[k] = Set.new }
  end

  def add_co_occurrence(name1, name2, weight = 1)
    return if name1 == name2
    @co_occurrence[name1][name2] += weight
    @co_occurrence[name2][name1] += weight
    @name_variants[name1] << name1
    @name_variants[name2] << name2
  end  

  def jaccard_similarity(name1, name2)
    neighbors1 = @co_occurrence[name1].keys.to_set
    neighbors2 = @co_occurrence[name2].keys.to_set
    return 0 if neighbors1.empty? || neighbors2.empty?
    intersection = (neighbors1 & neighbors2).size
    union = (neighbors1 | neighbors2).size
    intersection.to_f / union
  end

  def cluster_entities(threshold = 0.3)
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

  def disambiguate(name, known_entities, fallback_threshold = 0.85)
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

  def load_variant_map(map, edge_weight: 3.0)
    count = 0
    map.each do |canonical, variants|
      variants.each do |variant|
        next if variant == canonical
        add_synonym(canonical, variant, edge_weight)
        count += 1
        puts "🔗 #{canonical} ↔ #{variant}" if count % 100 == 0
      end
    end
    puts "✅ Added #{count} synonym edges from variant map"
  end
end
