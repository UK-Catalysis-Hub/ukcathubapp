require "test_helper"

class AuthorDisambiguationTest < ActiveSupport::TestCase
  setup do
    @ads = AuthorDisambiguationService.new()

    # Simulate 3 real people with multiple name variants
    # Person 1: Dr. Carl Williams (AI researcher)
    @collaboration_examples = [
        ["Carl Williams", "Alice Brown"],
        ["Carl Williams", "Bob Smith"],
        ["Carl Williams", "Alice Brown", 3],  # weighted - frequent collaborators
        ["C. Williams", "Alice Brown"],
        ["C. Williams", "Bob Smith"],
        ["Charlie Williams", "Alice Brown"],
        ["Dr. C. Williams", "Bob Smith"],
    # Person 2: Charles Williams (Biologist) - distinct from Carl
        ["Charles Williams", "Diana Ross"],
        ["Charles Williams", "Evan Wright"],
        ["Chas Williams", "Diana Ross"],
        ["Charles Willians", "Evan Wright"],  # misspelling
    # Person 3: William Carlos (Poetry scholar) - shares "William" but different
        ["William Carlos", "Emily Dickinson"],
        ["W. Carlos", "Emily Dickinson"],
        ["Bill Carlos", "Emily Dickinson"],
        ["Bill Carlos", "Robert Frost"]]
    @known_entities ={
        "E001" => Set.new(["Carl Williams", "C. Williams", "Charlie Williams", "Dr. C. Williams"]),
        "E002" => Set.new(["Charles Williams", "Chas Williams", "Charles Willians"]),
        "E003" => Set.new(["William Carlos", "W. Carlos", "Bill Carlos"])}
    @test_names = [
        "Carlos Williams",     # Should match E001 (Carl)
        "C. Willians",         # Should match E001 (typo of C. Williams)
        "Chuck Williams",      # New nickname - unknown, fallback to string
        "Charlie Willians",    # Should match E001 (Charlie Williams + typo)
        "Dr. Charles W.",      # Should match E002 (Charles)
        "William Carlos Jr.",  # Should match E003
       "Sarah Chen"           # Completely new person - no match
    ]
  end
  
  test "should add occurences to graph" do
    @collaboration_examples.each do |a_collaboration|
      @ads.add_co_occurrence(*a_collaboration)
    end
    clusters = @ads.cluster_entities(threshold= 0.3)
    assert 8, clusters.length
    
  end
end
