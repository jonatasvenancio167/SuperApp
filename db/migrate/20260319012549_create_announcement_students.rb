class CreateAnnouncementStudents < ActiveRecord::Migration[7.2]
  def change
    create_table :announcement_students do |t|
      t.references :announcement, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true

      t.timestamps
    end
  end
end
