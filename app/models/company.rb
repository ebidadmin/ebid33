class Company < ActiveRecord::Base
  attr_accessible :name, :nickname, :primary_role, :trial_start, :trial_end, :metering_date, :perf_ratio
end
