class RecipientResolver
  def self.call(announcement)
    new(announcement).call
  end

  def initialize(announcement)
    @announcement = announcement
  end
 
  def call
    case @announcement.scope
    when "school"      then resolve_school
    when "classrooms"  then resolve_classrooms
    when "students"    then resolve_students
    else []
    end
  end

  private
 
  def resolve_school
    Guardian
      .joins(students: :classrooms)
      .where(classrooms: { school_id: @announcement.school_id })
      .distinct
      .pluck(:id)
  end
 
  # Responsáveis dos alunos das turmas selecionadas
  def resolve_classrooms
    classroom_ids = AnnouncementClassroom
                      .where(announcement_id: @announcement.id)
                      .pluck(:classroom_id)
 
    return [] if classroom_ids.empty?
 
    Guardian
      .joins(students: :classrooms)
      .where(classrooms: { id: classroom_ids })
      .distinct
      .pluck(:id)
  end
 
  # Responsáveis dos alunos selecionados diretamente
  def resolve_students
    student_ids = AnnouncementStudent
                    .where(announcement_id: @announcement.id)
                    .pluck(:student_id)
 
    return [] if student_ids.empty?
 
    Guardian
      .joins(:students)
      .where(students: { id: student_ids })
      .distinct
      .pluck(:id)
  end
end