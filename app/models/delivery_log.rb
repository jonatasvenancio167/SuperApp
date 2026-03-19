class DeliveryLog < ApplicationRecord
  belongs_to :announcement
  belongs_to :guardian
end
