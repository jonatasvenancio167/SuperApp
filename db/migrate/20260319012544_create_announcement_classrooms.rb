class CreateAnnouncementClassrooms < ActiveRecord::Migration[7.2]
  def change
    create_table :announcement_classrooms, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :announcement, null: false, foreign_key: true, type: :uuid
      t.references :classroom, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
