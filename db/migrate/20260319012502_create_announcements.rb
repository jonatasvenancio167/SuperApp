class CreateAnnouncements < ActiveRecord::Migration[7.2]
  def change
    create_table :announcements do |t|
      t.references :school, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.string :attachment_url
      t.string :scope
      t.string :status
      t.datetime :sent_at

      t.timestamps
    end
  end
end
