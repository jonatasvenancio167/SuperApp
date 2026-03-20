class Announcement < ApplicationRecord
  belongs_to :school
  has_many :announcement_classrooms, dependent: :destroy
  has_many :classrooms, through: :announcement_classrooms
  has_many :announcement_students, dependent: :destroy
  has_many :students, through: :announcement_students
  has_many :delivery_logs, dependent: :destroy
 
  enum :status, { draft: "draft", sending: "sending", sent: "sent" }, default: "draft"
  enum :scope,  { school: "school", classrooms: "classrooms", students: "students" }
 
  validates :title,   presence: true
  validates :content, presence: true
  validates :scope,   presence: true
  validates :status,  presence: true
 
  scope :by_school, ->(school_id) { where(school_id: school_id) }
  scope :sent,      -> { where(status: "sent") }
  scope :drafts,    -> { where(status: "draft") }
end
