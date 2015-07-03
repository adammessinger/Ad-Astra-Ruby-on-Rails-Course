class User < ActiveRecord::Base
  has_many :reports, class_name: :Bug, foreign_key: :reporter_id, dependent: :nullify
  has_many :assignments, class_name: :Bug, foreign_key: :assignee_id, dependent: :nullify
  has_many :comments, foreign_key: :author_id, dependent: :nullify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
