class Phone < ActiveRecord::Base
  belongs_to(:contact)

  validates(:number, :contact_id, :presence => true)
end
