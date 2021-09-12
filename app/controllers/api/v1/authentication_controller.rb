module Api
  module V1
    # this controller handles successful/failed sign-ins of accounts
    class AuthenticationController < ApplicationController
      class AuthenticateError < StandardError; end

      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      rescue_from AuthenticateError, with: :handle_unauthenticated

      def create
        if account
          raise AuthenticateError unless account.authenticate(params.require(:password))

          render json: AccountPresenter.new(account).as_json, status: :created
        else
          render json: { error: I18n.t('accounts.login.errors.not_found') }, status: :unauthorized
        end
      end

      private

      def account
        @account ||= Account.find_by(email: params.require(:email))
      end

      def parameter_missing(error)
        render json: { error: error.message }, status: :unprocessable_entity
      end

      def handle_unauthenticated
        render json: { error: I18n.t('accounts.login.errors.authentication') }, status: :unauthorized
      end
    end
  end
end