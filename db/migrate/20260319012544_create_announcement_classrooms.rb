class CreateAnnouncementClassrooms < ActiveRecord::Migration[7.2]
  def change
    create_table :announcement_classrooms do |t|
      t.references :announcement, null: false, foreign_key: true
      t.references :classroom, null: false, foreign_key: true

      t.timestamps
    end
  end
end
