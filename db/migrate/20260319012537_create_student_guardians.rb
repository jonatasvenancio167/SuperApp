class CreateStudentGuardians < ActiveRecord::Migration[7.2]
  def change
    create_table :student_guardians, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :student, null: false, foreign_key: true, type: :uuid
      t.references :guardian, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
