class Guardian < ApplicationRecord
  has_many :student_guardians
  has_many :students, through: :student_guardians
  has_many :delivery_logs, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
