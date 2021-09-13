class AddColumnsToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :password_digest, :string
    add_column :accounts, :amount, :decimal, default: 0.0, precision: 15, scale: 2
  end
end
