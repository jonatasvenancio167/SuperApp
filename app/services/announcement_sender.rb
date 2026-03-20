class AnnouncementSender
  Result = Struct.new(:success?, :error)

  def self.call(announcement)
    new(announcement).call
  end

  def initialize(announcement)
    @announcement = announcement
  end

  def call
    return Result.new(false, "Comunicado já enviado ou em processamento") unless @announcement.draft?
    return Result.new(false, "Comunicado não tem destinatários configurados") unless recipients_configured?
 
    ActiveRecord::Base.transaction do
      @announcement.update!(status: :sending, sent_at: Time.current)
      AnnouncementDispatchJob.perform_later(@announcement.id)
    end
 
    Result.new(true, nil)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(false, e.message)
  end

  private

  def recipients_configured?
    case @announcement.scope
    when "school"      then true
    when "classrooms"  then AnnouncementClassroom.exists?(announcement_id: @announcement.id)
    when "students"    then AnnouncementStudent.exists?(announcement_id: @announcement.id)
    else false
    end
  end
end