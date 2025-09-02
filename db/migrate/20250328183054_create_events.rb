class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :date
      t.string :venue
      t.references :organizer, null: false, foreign_key: { to_table: :users } # Foreign key to users table for the event organizer

      t.timestamps
    end
  end
end
