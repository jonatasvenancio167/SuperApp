class AnnouncementSerializer < Blueprinter::Base
  identifier :id

  fields :title, :content, :attachment_url, :scope, :status, :sent_at,
         :created_at, :updated_at

  association :school, blueprint: SchoolSerializer

  view :with_stats do
    field :stats do |announcement|
      AnnouncementStatsQuery.call(announcement)
    end

    association :classrooms, blueprint: ClassroomSerializer
  end
end