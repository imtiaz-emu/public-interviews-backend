# frozen_string_literal: true
class ApplicationController < ActionController::API
  def authenticate_request!
    return unauthorized_account if !payload || !AuthenticationTokenService.valid_payload(payload.first)

    current_account
    unauthorized_account unless @current_account
  end

  def current_account
    @current_account = Account.find_by(id: payload[0]['account_id'])
  end

  private

  def payload
    auth_header = request.headers['Authorization']
    token = auth_header.split(' ').last
    AuthenticationTokenService.decode(token)
  rescue StandardError
    nil
  end

  def unauthorized_account
    render json: { error: I18n.t('accounts.login.errors.unauthorized') }, status: :unauthorized
  end
end
