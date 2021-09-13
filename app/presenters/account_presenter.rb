# This class represents an Account by sending a serialized json data
class AccountPresenter
  def initialize(account)
    @account = account
  end

  def as_json
    {
      id: @account.id,
      email: @account.email,
      phone: @account.phone_number,
      token: AuthenticationTokenService.call(@account.id)
    }
  end

  private

  attr_reader :account
end