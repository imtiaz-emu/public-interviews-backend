require 'rails_helper'
require 'rspec_api_documentation/dsl'

RSpec.resource 'Accounts' do
  header 'Accept', 'application/json'

  post '/api/v1/register' do
    parameter :account, type: Hash, required: true, items: {
      first_name: :string, last_name: :string,
      phone_number: :string, email: :string,
      password: :string
    }

    let(:account) {
      {
        first_name: Faker::Name.first_name, last_name: Faker::Name.last_name,
        phone_number: Faker::PhoneNumber.cell_phone_in_e164, email: Faker::Internet.email,
        password: 'password'
      }
    }

    example 'Create a new account' do
      explanation 'Apply for a new account'
      do_request
      expect(status).to eq(201)
    end
  end
end