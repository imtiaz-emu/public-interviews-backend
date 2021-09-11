require 'rails_helper'

RSpec.describe 'Accounts', type: :request do
  describe 'POST /register' do
    it 'authenticates the account' do
      post '/api/v1/register', params: {
        account: {
          first_name: 'Imtiaz', last_name: 'Emu', email: 'emu@gmail.com', phone_number: '+88012312324', password: 'password'
        }
      }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq({
        'id' => Account.last.id,
        'email' => Account.last.email,
        'phone' => Account.last.phone_number,
        'token' => AuthenticationTokenService.call(Account.last.id)
      })
    end
  end
end
