class DeliveryLogSerializer < Blueprinter::Base
  identifier :id
  fields :read, :read_at, :created_at
  association :guardian, blueprint: GuardianSerializer
end