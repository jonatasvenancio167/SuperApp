class RecipientResolver
  CACHE_TTL = 5.minutes

  def self.call(announcement)
    new(announcement).call
  end

  def initialize(announcement)
    @announcement = announcement
  end
 
  def call
    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      case @announcement.scope
      when "school"      then resolve_school
      when "classrooms"  then resolve_classrooms
      when "students"    then resolve_students
      else []
      end
    end
  end

  private
 
  def cache_key
    "recipient_resolver/#{@announcement.scope}/#{scope_identifier}/v1"
  end

  def resolve_school
    classrooms = Classroom.where(school_id: @announcement.school_id)
                          .includes(students: :guardians)
 
    extract_guardian_ids(classrooms)
  end
 
  # Responsáveis dos alunos das turmas selecionadas
  def resolve_classrooms
    classroom_ids = AnnouncementClassroom
                      .where(announcement_id: @announcement.id)
                      .pluck(:classroom_id)
 
    return [] if classroom_ids.empty?
 
    classrooms = Classroom.where(id: classroom_ids)
                          .includes(students: :guardians)
                        
    extract_guardian_ids(classrooms)
  end
 
  # Responsáveis dos alunos selecionados diretamente
  def resolve_students
    student_ids = AnnouncementStudent
                    .where(announcement_id: @announcement.id)
                    .pluck(:student_id)
 
    return [] if student_ids.empty?
 
    students = Student.where(id: student_ids)
                      .includes(:guardians)

    students.flat_map { |s| s.guardians.map(&:id) }.uniq
  end

  def extract_guardian_ids(classrooms)
    classrooms
      .flat_map { |classroom| classroom.students }
      .flat_map { |student| student.guardians }
      .map(&:id)
      .uniq
  end

  def scope_identifier
    case @announcement.scope
    when "school"     then @announcement.school_id
    when "classrooms" then @announcement.id
    when "students"   then @announcement.id
    end
  end
end