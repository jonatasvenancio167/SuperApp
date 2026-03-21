class AddUniqueIndexToStudentGuardians < ActiveRecord::Migration[7.2]
  def change
    add_index :student_guardians, [:student_id, :guardian_id], unique: true,
              name: "index_student_guardians_on_student_id_and_guardian_id"
  end
end
