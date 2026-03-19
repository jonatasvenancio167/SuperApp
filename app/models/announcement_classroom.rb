class AnnouncementClassroom < ApplicationRecord
  belongs_to :announcement
  belongs_to :classroom
end