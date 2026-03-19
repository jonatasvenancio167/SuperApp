class Classroom < ApplicationRecord
  belongs_to :school
  has_many :student_classrooms, dependent: :destroy
  has_many :students, through: :student_classrooms
  has_many :announcement_classrooms, dependent: :destroy
  has_many :announcements, through: :announcement_classrooms

  validates :name, presence: true
  validates :grade, presence: true
end
