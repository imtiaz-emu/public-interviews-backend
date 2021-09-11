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
#  status          :integer          default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_accounts_on_email         (email)
#  index_accounts_on_phone_number  (phone_number)
#  index_accounts_on_status        (status)
#
class Account < ApplicationRecord
  has_secure_password

  validates :first_name, :last_name, :email, :phone_number, presence: true
  validates :email, uniqueness: true
  validates :phone_number, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  enum status: {
    unverified: -1,
    pending: 0,
    verified: 1
  }, _suffix: true
end
