class User < ActiveRecord::Base
  has_many :reports, class_name: 'Bug', foreign_key: 'reporter_id'
  has_many :assignments, class_name: 'Bug', foreign_key: 'assignee_id'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
