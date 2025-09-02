class Addwiatlisttobookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :waitlist, :boolean, default: false
  end
end
