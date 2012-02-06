class Term < ActiveRecord::Base
  has_many :cart_entries
  has_many :entries

  def term_name
    if self.id == 1
      "Cash"
    else
      "#{name} days"
    end
  end
end
