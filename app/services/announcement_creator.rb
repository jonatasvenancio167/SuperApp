class AnnouncementCreator
  Result = Struct.new(:success?, :announcement, :error)

  def self.call(school:, params:)
    new(school: school, params: params).call
  end

  def initialize(school:, params:)
    @school = school
    @params = params.to_h.with_indifferent_access
  end

  def call
    ActiveRecord::Base.transaction do
      announcement = @school.announcements.new(@params)

      unless announcement.save!
        return Result.new(false, announcement, announcement.errors.full_messages)
      end

      attach_recipients!(announcement)

      Result.new(true, announcement, [])
    end

  rescue ActiveRecord::RecordInvalid => e
    Result.new(false, nil, [e.message])
  rescue ArgumentError => e
    Result.new(false, nil, [e.message])
  end

  private 

  def base_params
    @params.slice(:title, :content, :attachment_url, :scope)
  end

  def attach_recipients!(announcement)
    case announcement.scope
    when "classrooms"
      ids = Array(@params[:classroom_ids]).compact.uniq
      raise ArgumentError, "Deve informar pelo menos uma turma" if ids.empty?
      
      validate_classrooms_belong_to_school!(ids)

      AnnouncementClassroom.insert_all!(
        ids.map { |id| { announcement_id: announcement.id, classroom_id: id } }
      )
    when "students"
      ids = Array(@params[:student_ids]).compact.uniq
      raise ArgumentError, "Selecione ao menos um aluno" if ids.empty?
 
      AnnouncementStudent.insert_all!(
        ids.map { |id| { announcement_id: announcement.id, student_id: id } }
      )
    when "school"
      nil
    end
  end

  def validate_classrooms_belong_to_school!(classroom_ids)
    valid_ids = Classroom.where(id: classroom_ids, school_id: @school.id).pluck(:id)
    invalid   = classroom_ids - valid_ids

    raise ArgumentError, "Turmas inválidas: #{invalid.join(", ")}" if invalid.any?
  end
end
