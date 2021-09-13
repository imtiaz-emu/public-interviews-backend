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
require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let!(:sender) { create(:account, amount: 1000) }
  let!(:receiver) { create(:account, amount: 1000) }
  subject { described_class.new(sender: sender, receiver: receiver, amount: 5) }

  it { expect(subject).to be_valid }
  it { should belong_to(:receiver) }

  context 'amount is negative' do
    it 'is invalid' do
      subject = described_class.new(sender: sender, receiver: receiver, amount: 10_000)
      expect(subject).to_not be_valid
      expect(subject.errors[:error]).to include('Balance low')
    end
  end
end
