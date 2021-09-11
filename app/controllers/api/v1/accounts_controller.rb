module Api
  module V1
    # This controller handles successful/failed registration of accounts
    class AccountsController < ApplicationController
      def create
        account = Account.new(account_params)

        if account.save
          render json: AccountPresenter.new(account).as_json, status: :created
        else
          render json: { error: account.errors.full_messages.first }, status: :unprocessable_entity
        end
      end

      private

      def account_params
        params.require(:account).permit(:first_name, :last_name, :phone_number, :email, :password)
      end
    end
  end
end