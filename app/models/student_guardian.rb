class StudentGuardian < ApplicationRecord
  belongs_to :student
  belongs_to :guardian

  after_create  :invalidate_cache
  after_destroy :invalidate_cache

  private

  def invalidate_cache
    student.classrooms.select(:school_id).distinct.each do |classroom|
      Rails.cache.delete_matched("recipient_resolver/school/#{classroom.school_id}*")
    end
  end 
end