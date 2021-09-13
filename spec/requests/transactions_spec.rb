require 'rails_helper'

RSpec.describe 'Transactions', type: :request do
  # initialize test data
  let!(:sender) { FactoryBot.create(:account, email: 'sender@gmail.com', password: 'password', amount: 100.0) }
  let!(:receiver) { FactoryBot.create(:account, email: 'receiver@gmail.com', password: 'password', amount: 100.0) }

  describe 'GET /transactions' do
    let!(:transaction1) { FactoryBot.create(:transaction, sender: sender, receiver: receiver, amount: 10.0) }
    let!(:transaction2) { FactoryBot.create(:transaction, sender: receiver, receiver: sender, amount: 10.0) }

    context 'Checking outbound transactions', type: :request do
      before {
        get '/api/v1/transactions', headers: {
          'Authorization' => AuthenticationTokenService.call(sender.id)
        }
      }

      it 'returns outbound transactions' do
        expect(JSON.parse(response.body)).not_to be_nil
        expect(JSON.parse(response.body)).to be_a_kind_of(Array)
        expect(JSON.parse(response.body).first['id']).to eq(transaction1.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'Checking inbound transactions', type: :request do
      before {
        get '/api/v1/transactions?inbound=1', headers: {
          'Authorization' => AuthenticationTokenService.call(sender.id)
        }
      }

      it 'returns inbound transactions' do
        expect(JSON.parse(response.body)).not_to be_nil
        expect(JSON.parse(response.body)).to be_a_kind_of(Array)
        expect(JSON.parse(response.body).first['id']).to eq(transaction2.id)
      end
    end

    context 'Checking statuses' do
      describe 'Checking 401 status' do
        before {
          get '/api/v1/transactions', headers: {
            'Authorization' => nil
          }
        }

        it 'returns status code 401' do
          expect(response).to have_http_status(401)
        end
      end
    end
  end

  describe 'GET /transactions/:id' do
    let!(:transaction) { FactoryBot.create(:transaction, sender: sender, receiver: receiver, amount: 10.0) }
    let!(:transaction_id) { transaction.id }

    before {
      get "/api/v1/transactions/#{transaction_id}", headers: {
        'Authorization' => AuthenticationTokenService.call(sender.id)
      }
    }

    context 'when transaction exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the transaction item' do
        expect(JSON.parse(response.body)['id']).to eq(transaction.id)
      end
    end

    context 'when transaction does not exist' do
      let(:transaction_id) { 0 }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when transaction access unauthorized' do
      let!(:sender1) { FactoryBot.create(:account, email: 'sender1@gmail.com', password: 'password', amount: 100.0) }

      before {
        get "/api/v1/transactions/#{transaction_id}", headers: {
          'Authorization' => AuthenticationTokenService.call(sender1.id)
        }
      }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  describe 'POST /transactions' do
    let(:valid_attributes1) do
      { email: receiver.email, amount: 10.0 }
    end

    let(:valid_attributes2) do
      { phone: receiver.phone_number, amount: 10.0 }
    end

    let(:valid_attributes3) do
      { phone: receiver.phone_number, amount: 10.0, email: receiver.email }
    end

    let(:invalid_attributes1) do
      { phone: nil, amount: 10.0, email: nil }
    end

    let(:invalid_attributes2) do
      { phone: receiver.phone_number, amount: 20_000.0 }
    end

    let(:invalid_attributes3) do
      { phone: receiver.phone_number, amount: -10.0 }
    end

    context 'when attributes are valid but sender is non-verified' do
      describe 'transfer money with email' do
        before {
          post '/api/v1/transactions', params: valid_attributes1, headers: {
            'Authorization' => AuthenticationTokenService.call(sender.id)
          }
        }

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
          expect(Transaction.count).to eq(0)
        end
      end
    end

    context 'when request attributes and accounts are valid' do
      before do
        sender.update_column(:status, Account.statuses[:verified])
        receiver.update_column(:status, Account.statuses[:verified])
      end

      describe 'transfer money with email' do
        before {
          post '/api/v1/transactions', params: valid_attributes1, headers: {
            'Authorization' => AuthenticationTokenService.call(sender.id)
          }
        }

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
          expect(Transaction.count).to eq(1)
        end

        it 'checks sender balance' do
          expect(receiver.reload.amount).to eq(110.0)
        end

        it 'checks receiver balance' do
          expect(sender.reload.amount).to eq(90.0)
        end
      end

      describe 'transfer money with phone number' do
        before {
          post '/api/v1/transactions', params: valid_attributes1, headers: {
            'Authorization' => AuthenticationTokenService.call(sender.id)
          }
        }

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
          expect(Transaction.count).to eq(1)
        end

        it 'checks sender balance' do
          expect(receiver.reload.amount).to eq(110.0)
        end

        it 'checks receiver balance' do
          expect(sender.reload.amount).to eq(90.0)
        end
      end

      describe 'transfer money with phone and email' do
        before {
          post '/api/v1/transactions', params: valid_attributes3, headers: {
            'Authorization' => AuthenticationTokenService.call(sender.id)
          }
        }

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
          expect(Transaction.count).to eq(1)
        end

        it 'checks sender balance' do
          expect(receiver.reload.amount).to eq(110.0)
        end

        it 'checks receiver balance' do
          expect(sender.reload.amount).to eq(90.0)
        end
      end
    end

    context 'when request attributes are invalid' do
      before do
        sender.update_column(:status, Account.statuses[:verified])
        receiver.update_column(:status, Account.statuses[:verified])
      end

      describe 'transfer money without email or phone' do
        before {
          post '/api/v1/transactions', params: invalid_attributes1, headers: {
            'Authorization' => AuthenticationTokenService.call(sender.id)
          }
        }

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
          expect(JSON.parse(response.body)).to eq({
            'error' => 'Receiver not found'
          })
        end
      end

      describe 'transfer money with insufficient balance' do
        before {
          post '/api/v1/transactions', params: invalid_attributes2, headers: {
            'Authorization' => AuthenticationTokenService.call(sender.id)
          }
        }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)).to eq({
            'error' => ['Balance low']
          })
        end
      end

      describe 'transfer money with negative amount' do
        before {
          post '/api/v1/transactions', params: invalid_attributes3, headers: {
            'Authorization' => AuthenticationTokenService.call(sender.id)
          }
        }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)['amount']).to eq ['must be greater than or equal to 1.0']
        end
      end
    end
  end
end