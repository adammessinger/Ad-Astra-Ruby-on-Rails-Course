class Bug < ActiveRecord::Base
  belongs_to :reporter, class_name: "User", foreign_key: 'id', validate: true
  belongs_to :assignee, class_name: "User", foreign_key: 'id', validate: true

  validates(:title, presence: true)
  validates(:reporter_id, presence: true)
  validates(:description, presence: true)
end
