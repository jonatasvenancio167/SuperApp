class AddUniqueIndexToStudentClassrooms < ActiveRecord::Migration[7.2]
  def change
    add_index :student_classrooms, [:student_id, :classroom_id], unique: true,
            name: "index_student_classrooms_on_student_id_and_classroom_id"
  end
end
