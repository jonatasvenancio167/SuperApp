class ClassroomSerializer < Blueprinter::Base
  identifier :id

  fields :name, :grade
end