# temps = TempCompany.all
# temps.each do |comp|
#   c = Company.create(name: comp.name, nickname: comp.name.split(/ /)[0], primary_role: comp.primary_role, trial_start: comp.trial_start,
#     trial_end: comp.trial_end, metering_date: comp.metering_date, perf_ratio: comp.perf_ratio, created_at: comp.created_at,
#     updated_at: comp.updated_at)
#   b = Branch.create(company_id: c.id, name: 'Main', address1: comp.address1, address2: comp.address2,
#     zip_code: comp.zip_code, city_id: comp.city_id, created_at: comp.created_at, updated_at: comp.updated_at)
# end
# messages = Message.all
# messages.each do |m|
#   
# end

# profiles = Profile.all
# profiles.each { |p| p.update_attributes(first_name: p.first_name, last_name: p.last_name, branch_id: p.company_id) } 
# 
bwo = Bid.with_orders.not_cancelled
bwo.each do |b|
  b.line_item.update_attribute(:order_id, b.order_id)
  # b.line_item.update_attribute(:status, b.status)
end

# bids = Bid.cancelled
# bids.each { |b| b.update_attribute(:status, 'Cancelled') }
# 
rel = Entry.where(status: ['Additional', 'Relisted'], relisted: nil)
rel.each do |r|
  r.update_attribute(:relisted, r.online)
end
# 
# orders = Order.all
# orders.each { |o| o.update_attribute(:seller_company_id, o.seller.company.id) }
# ids = orders.map(&:entry_id).uniq
# entries = Entry.find(ids)
# entries.each { |e| e.update_attribute(:orders_count, e.orders.count) }

# Photo.find_each(batch_size: 500) { |p| p.photo.reprocess! }

LineItem.find_each do |li|
  LineItem.reset_counters li.id, :bids
end

User.find_each do |u|
  User.reset_counters u.id, :entries
end

