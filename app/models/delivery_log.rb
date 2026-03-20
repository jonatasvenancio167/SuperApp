class DeliveryLog < ApplicationRecord
  belongs_to :announcement
  belongs_to :guardian

  scope :read,   -> { where(read: true) }
  scope :unread, -> { where(read: false) }

  def mark_as_read!
    update(read: true, read_at: Time.current)
  end
end
