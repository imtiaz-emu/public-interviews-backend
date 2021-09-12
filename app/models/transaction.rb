# == Schema Information
#
# Table name: transactions
#
#  id          :bigint           not null, primary key
#  amount      :decimal(15, 2)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  receiver_id :bigint
#  sender_id   :bigint
#
# Indexes
#
#  index_transactions_on_receiver_id  (receiver_id)
#  index_transactions_on_sender_id    (sender_id)
#
class Transaction < ApplicationRecord
  belongs_to :sender, class_name: 'Account'
  belongs_to :receiver, class_name: 'Account'

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 1.0 }
  validate :low_account_balance

  after_create :account_amount_adjustment

  private

  def low_account_balance
    errors.add(:error, 'Balance low') if sender.amount < amount
  end

  def account_amount_adjustment
    sender.update_column(:amount, sender.amount - amount)
    receiver.update_column(:amount, receiver.amount + amount)
  end
end
