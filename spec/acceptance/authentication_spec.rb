require 'rails_helper'
require 'rspec_api_documentation/dsl'

RSpec.resource 'Authentication' do
  let!(:sender) { FactoryBot.create(:account, email: 'sender@gmail.com', password: 'password', amount: 100.0) }

  header 'Accept', 'application/json'
  header 'Authorization', :auth_token

  post '/api/v1/login' do
    parameter :email, type: String, required: true
    parameter :password, type: String, required: true

    let(:email) { sender.email }
    let(:password) { 'password' }

    example 'Account login' do
      explanation 'Login to account'
      do_request
      expect(status).to eq(201)
    end
  end
end