class GuardianSerializer < Blueprinter::Base
  identifier :id

  fields :name, :email
end
