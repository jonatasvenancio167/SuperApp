class Student < ApplicationRecord
  has_many :student_classrooms
  has_many :classrooms, through: :student_classrooms
  has_many :student_guardians
  has_many :guardians, through: :student_guardians
  has_many :announcement_students, dependent: :destroy
  has_many :announcements, through: :announcement_students

  validates :name, presence: true
  
end
