class AuthorCollaboration < ApplicationRecord
  #self.primary_key = nil
  
  belongs_to :author_a,
    class_name: "Author",
    foreign_key: :author_source
    
  belongs_to :author_b,
    class_name: "Author",
    foreign_key: :author_target
    
  def readonly?
    true
  end
end
