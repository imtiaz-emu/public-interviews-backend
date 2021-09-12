module Api
  module V1
    class TransactionsController < ApplicationController
      before_action :authenticate_request!
      before_action :set_transaction, only: %i[show]
      before_action :forbid_transactions, only: %i[create]

      # GET /transactions
      def index
        @transactions = @current_account.outbound_transactions.includes(:sender, :receiver)
        @transactions = @current_account.inbound_transactions.includes(:sender, :receiver) if params[:inbound] == '1'

        render json: TransactionsPresenter.new(@transactions).as_json
      end

      # POST /transactions
      def create
        @transaction = @current_account.outbound_transactions.new(transaction_params.slice(:amount))
        @transaction.receiver = transaction_receiver

        if @transaction.save
          render json: TransactionPresenter.new(@transaction).as_json, status: :created
        else
          render json: @transaction.errors, status: :unprocessable_entity
        end
      end

      # GET /transactions/:id
      def show
        if @transaction && @current_account.my_transaction?(@transaction)
          render json: TransactionPresenter.new(@transaction).as_json, status: :ok
        else
          render json: { error: I18n.t('transactions.errors.unauthorized') }, status: :forbidden
        end
      end

      private

      def set_transaction
        @transaction = Transaction.find_by(id: params[:id])
      end

      def transaction_params
        params.permit(:email, :phone, :amount)
      end

      def transaction_receiver
        sanitized_params = transaction_params.except(:amount).to_h.compact
        @transaction_receiver ||= fetch_receiver_by(sanitized_params)
      end

      def fetch_receiver_by(params)
        if params.keys.size == 2
          Account.find_by_email_phone(params[:email], params[:phone]).first
        elsif params.keys.include?('email')
          Account.find_by_email(params[:email]).first
        elsif params.keys.include?('phone')
          Account.find_by_phone(params[:phone]).first
        end
      end

      def receiver_not_found
        render json: { error: I18n.t('transactions.errors.receiver_not_found') }, status: :forbidden
      end

      def forbid_transactions
        return render_forbidden_transactions('Sender') unless @current_account.verified_status?
        return receiver_not_found unless transaction_receiver

        render_forbidden_transactions('Receiver') unless transaction_receiver.verified_status?
      end

      def render_forbidden_transactions(account)
        render json: { error: I18n.t('transactions.errors.account_unverified', subject: account) }, status: :forbidden
      end
    end
  end
end
