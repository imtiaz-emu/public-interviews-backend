class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.references :sender
      t.references :receiver
      t.decimal :amount, precision: 15, scale: 2

      t.timestamps
    end
  end
end
