# This class generates, encodes, decodes jwt auth tokens
class AuthenticationTokenService
  HMAC_SECRET = Rails.application.secrets.secret_key_base
  ALGORITHM_TYPE = 'HS256'.freeze

  def self.call(account_id)
    exp = 24.hours.from_now.to_i
    payload = { account_id: account_id, exp: exp }
    JWT.encode payload, HMAC_SECRET, ALGORITHM_TYPE
  end

  def self.decode(token)
    JWT.decode token, HMAC_SECRET, true, { algorithm: ALGORITHM_TYPE }
  rescue JWT::ExpiredSignature, JWT::DecodeError
    false
  end

  def self.valid_payload(payload)
    !expired(payload)
  end

  def self.expired(payload)
    Time.at(payload['exp']) < Time.now
  end

  def self.expired_token
    render json: { error: I18n.t('accounts.register.errors.token_expired') }, status: :unauthorized
  end
end