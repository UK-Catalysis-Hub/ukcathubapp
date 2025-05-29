module OrganisationsHelper
  def get_organisation_country_count
    inst_stats = Organisation.select('country, count(id) as inst_count')
    .group('country').order('count(id) desc')
    organisation_country_count = []
    inst_stats.each do |insts|
      if insts.country == "Peoples Republic of China" then
        organisation_country_count.append(["China", insts.inst_count])
      elsif insts.country == "United States of America" then
        organisation_country_count.append(["United States", insts.inst_count])
      elsif insts.country == "The Netherlands" then
        organisation_country_count.append(["Netherlands", insts.inst_count])
      else
        if insts.country != "United Kingdom"
          organisation_country_count.append([insts.country, insts.inst_count])
        end
      end
    end
    organisation_country_count
  end
  def get_organisation_uk_count
    inst_stats = Organisation.select('region, count(id) as inst_count')
    .group('region').order('count(id) desc').where("country = 'United Kingdom'")
    organisation_uk_count = []
    inst_stats.each do |insts|
      organisation_uk_count.append([insts.region, insts.inst_count])
    end
    organisation_uk_count
  end
end
