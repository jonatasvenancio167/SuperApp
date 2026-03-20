class SchoolSerializer < Blueprinter::Base
  identifier :id

  fields :name, :code
end