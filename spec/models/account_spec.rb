# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id              :bigint           not null, primary key
#  amount          :decimal(15, 2)   default(0.0)
#  email           :string
#  first_name      :string
#  last_name       :string
#  password_digest :string
#  phone_number    :string
#  status          :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_accounts_on_email         (email)
#  index_accounts_on_phone_number  (phone_number)
#  index_accounts_on_status        (status)
#
require 'rails_helper'

RSpec.describe Account, type: :model do
  subject(:account) { build(:account) }

  it 'has a valid factory' do
    expect(account).to be_valid
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to validate_presence_of(:email) }
    it { should_not validate_length_of(:password).is_at_least(5) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_uniqueness_of(:phone_number).case_insensitive }
  end

  describe '.find_by_email_phone' do
    it 'find accounts with email' do
      account = FactoryBot.create(:account)
      expect(Account.find_by_email(account.email)).to include(account)
    end

    it 'find accounts with email and phone' do
      account = FactoryBot.create(:account)
      expect(Account.find_by_email_phone(account.email, account.phone_number)).to include(account)
    end
  end
end
