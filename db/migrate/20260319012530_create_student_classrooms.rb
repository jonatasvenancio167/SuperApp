class CreateStudentClassrooms < ActiveRecord::Migration[7.2]
  def change
    create_table :student_classrooms do |t|
      t.references :student, null: false, foreign_key: true
      t.references :classroom, null: false, foreign_key: true

      t.timestamps
    end
  end
end
