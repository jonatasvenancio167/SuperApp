class AnnouncementDispatchJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: 3, dead: false

  BATCH_SIZE = 1_000

  def perform(announcement_id)
    announcement = Announcement.find_by(id: announcement_id)
 
    unless announcement
      Rails.logger.warn("[AnnouncementDispatchJob] Comunicado #{announcement_id} não encontrado. Ignorando.")
      return
    end
 
    unless announcement.sending?
      Rails.logger.warn("[AnnouncementDispatchJob] Comunicado #{announcement_id} não está em status 'sending' (atual: #{announcement.status}). Ignorando.")
      return
    end
 
    Rails.logger.info("[AnnouncementDispatchJob] Iniciando despacho do comunicado #{announcement_id}")
 
    guardian_ids = RecipientResolver.call(announcement)
 
    if guardian_ids.empty?
      Rails.logger.warn("[AnnouncementDispatchJob] Nenhum responsável encontrado para o comunicado #{announcement_id}")
      announcement.update!(status: :sent)
      return
    end
 
    Rails.logger.info("[AnnouncementDispatchJob] #{guardian_ids.size} responsáveis encontrados")
 
    create_delivery_logs!(announcement, guardian_ids)
 
    announcement.update!(status: :sent)
 
    Rails.logger.info("[AnnouncementDispatchJob] Comunicado #{announcement_id} enviado com sucesso")
  rescue => e
    announcement&.update_columns(status: "draft")
    Rails.logger.error("[AnnouncementDispatchJob] Erro ao despachar #{announcement_id}: #{e.message}")
    raise
  end

  private

  def create_delivery_logs!(announcement, guardian_ids)
    now = Time.current
 
    existing_guardian_ids = DeliveryLog
                              .where(announcement_id: announcement.id)
                              .pluck(:guardian_id)
                              .to_set
 
    pending_ids = guardian_ids.reject { |id| existing_guardian_ids.include?(id) }
 
    pending_ids.each_slice(BATCH_SIZE) do |batch|
      records = batch.map do |guardian_id|
        {
          announcement_id: announcement.id,
          guardian_id:     guardian_id,
          read:            false,
          created_at:      now,
          updated_at:      now
        }
      end
 
      DeliveryLog.insert_all!(records)
    end
  end
end