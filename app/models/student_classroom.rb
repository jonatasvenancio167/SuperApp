class StudentClassroom < ApplicationRecord
  belongs_to :student
  belongs_to :classroom

  after_create  :invalidate_school_cache
  after_destroy :invalidate_school_cache

  private

  def invalidate_school_cache
    school_id = classroom.school_id
    Rails.cache.delete_matched("recipient_resolver/school/#{school_id}*")
  end 
end