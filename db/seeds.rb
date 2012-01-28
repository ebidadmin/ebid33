# temps = TempCompany.all
# temps.each do |comp|
#   c = Company.create(name: comp.name, nickname: comp.name.split(/ /)[0], primary_role: comp.primary_role, trial_start: comp.trial_start,
#     trial_end: comp.trial_end, metering_date: comp.metering_date, perf_ratio: comp.perf_ratio, created_at: comp.created_at,
#     updated_at: comp.updated_at)
#   b = Branch.create(company_id: c.id, name: 'Main', address1: comp.address1, address2: comp.address2,
#     zip_code: comp.zip_code, city_id: comp.city_id, created_at: comp.created_at, updated_at: comp.updated_at)
# end

profiles = Profile.all
# profiles.each { |p| p.update_attribute(:branch_id, p.company_id) } 
profiles.each { |p| p.update_attributes(first_name: p.first_name, last_name: p.last_name) } 