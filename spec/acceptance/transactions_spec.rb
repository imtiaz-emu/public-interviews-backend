require 'rails_helper'
require 'rspec_api_documentation/dsl'

RSpec.resource 'Transactions' do
  let!(:sender) { FactoryBot.create(:account, email: 'sender@gmail.com', password: 'password', amount: 100.0) }
  let!(:receiver) { FactoryBot.create(:account, email: 'receiver@gmail.com', password: 'password', amount: 100.0) }
  let!(:transaction1) { FactoryBot.create(:transaction, sender: sender, receiver: receiver, amount: 10.0) }
  let!(:transaction2) { FactoryBot.create(:transaction, sender: receiver, receiver: sender, amount: 10.0) }
  let!(:auth_token) { AuthenticationTokenService.call(sender.id) }

  header 'Accept', 'application/json'
  header 'Authorization', :auth_token

  get '/api/v1/transactions' do
    parameter :inbound, 'in case if you want to see the inbound transactions'
    let(:inbound) { '1' }

    example 'Listing transactions' do
      explanation 'Retrieve all of the inbound transactions.'
      do_request
      expect(status).to eq(200)
    end
  end

  get '/api/v1/transactions/:id' do
    parameter :id, 'pass transaction id which you want to see'
    let(:id) { transaction1.id }

    example 'Details of transaction' do
      explanation 'Details about the transaction'
      do_request
      expect(status).to eq(200)
    end
  end

  post '/api/v1/transactions' do
    before do
      sender.update_column(:status, Account.statuses[:verified])
      receiver.update_column(:status, Account.statuses[:verified])
    end

    parameter :email, 'Receiver Email', optional: true
    parameter :phone, 'Receiver Phone Number', optional: true
    parameter :amount, 'Float value greater than or equal 1.0', required: true

    let(:email) { receiver.email }
    let(:amount) { 10.0 }

    example 'Create a new transaction' do
      explanation 'Apply for a new transaction'
      do_request
      expect(status).to eq(201)
    end
  end
end