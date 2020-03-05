class Affiliation < ApplicationRecord
  #relationships to authors and articles
  has_many :affiliation_links
  has_many :authors, through: :affiliation_links
  has_many :articles, through: :affiliation_links
  has_many :addresses, through: :affiliation_links
  def get_addresses
    addr_list = []
    addresses.each do |affi_address|
      if not addr_list.include?(affi_address)
        addr_list.push(affi_address)
      end
    end
    addr_list.sort()
  end
end
