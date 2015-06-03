class Contact < ActiveRecord::Base
  has_many(:phones, :dependent => :destroy)

  validates(:name, :presence => true)
end
