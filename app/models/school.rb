class School < ApplicationRecord
  has_many :classrooms, dependent: :destroy
  has_many :announcements, dependent: :destroy
  has_many :students, through: :classrooms

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
