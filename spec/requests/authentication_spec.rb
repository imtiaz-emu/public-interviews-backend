require 'rails_helper'

RSpec.describe 'Authentications', type: :request do
  describe 'POST /login' do
    let(:account) { create(:account, password: 'password') }

    it 'authenticates the user' do
      post '/api/v1/login', params: { email: account.email, password: 'password' }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq({
        'id' => account.id,
        'email' => account.email,
        'phone' => account.phone_number,
        'token' => AuthenticationTokenService.call(account.id)
      })
    end

    it 'returns error when email does not exist' do
      post '/api/v1/login', params: { email: 'null', password: 'password' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to eq({
        'error' => 'Account not found'
      })
    end

    it 'returns error when password is incorrect' do
      post '/api/v1/login', params: { email: account.email, password: 'incorrect' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to eq({
        'error' => 'Email/Password Incorrect'
      })
    end
  end
end