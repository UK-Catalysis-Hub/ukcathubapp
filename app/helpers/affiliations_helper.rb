module AffiliationsHelper
  def get_country_counts
    aff_stats = InstCtryStat.all.order('inst_count desc')
    country_data = []
    aff_stats.each do |affsts|
      if affsts.country == "Peoples Republic of China" then
        country_data.append(["China", affsts.inst_count])
      elsif affsts.country == "United States of America" then
        country_data.append(["United States", affsts.inst_count])
      elsif affsts.country == "The Netherlands" then
        country_data.append(["Netherlands", affsts.inst_count])
      else
        if affsts.country != "United Kingdom"
          country_data.append([affsts.country, affsts.inst_count])
        end
      end
    end
    country_data
  end

  def get_uk_count
    inst_stats = inst_stats = Organisation.where(id: Affiliation.joins(:author_affiliations).select(:organisation_id)).where("country = 'United Kingdom'").group(:region).count

    organisation_uk_count = inst_stats.map { |region, count| [region, count] }

    organisation_uk_count
  end
end
