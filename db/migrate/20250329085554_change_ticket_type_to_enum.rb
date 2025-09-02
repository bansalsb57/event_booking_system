class ChangeTicketTypeToEnum < ActiveRecord::Migration[8.0]
  def change
    change_column :tickets, :ticket_type, :integer, default: 0, using: 'ticket_type::integer'
  end
end
