class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :companies, :foreign_key => "primary_role"
end
