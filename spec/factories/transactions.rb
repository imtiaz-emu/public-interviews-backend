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
FactoryBot.define do
  factory :transaction do
    amount { Faker::Number.decimal(l_digits: 2) }
  end
end
