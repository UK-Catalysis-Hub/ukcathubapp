class AuthorCollaboration < ApplicationRecord
  self.primary_key = nil
  
  belongs_to :author_source,
    class_name: "Author",
    foreign_key: :author_source_id
    
  belongs_to :author_target,
    class_name: "Author",
    foreign_key: :author_target_id
    
  def readonly?
    true
  end
end
