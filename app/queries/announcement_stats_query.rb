class AnnouncementStatsQuery
  def self.call(announcement)
    new(announcement).call
  end

  def initialize(announcement)
    @announcement = announcement
  end

  def call
    counts = DeliveryLog
               .where(announcement_id: @announcement.id)
               .group(:read)
               .count
 
    read_count   = counts[true]  || 0
    unread_count = counts[false] || 0
    total        = read_count + unread_count
 
    {
      total:           total,
      read:            read_count,
      unread:          unread_count,
      read_percentage: total.zero? ? 0.0 : (read_count.to_f / total * 100).round(2),
      status:          @announcement.status,
      sent_at:         @announcement.sent_at
    }
  end
end
