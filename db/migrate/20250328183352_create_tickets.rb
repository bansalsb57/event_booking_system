class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.string :ticket_type
      t.decimal :price
      t.integer :quantity_available
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
