# return a single transaction
class TransactionPresenter
  def initialize(transaction)
    @transaction = transaction
  end

  def as_json
    {
      id: @transaction.id,
      sender: {
        phone: @transaction.sender.phone_number,
        email: @transaction.sender.email
      },
      receiver: {
        phone: @transaction.receiver.phone_number,
        email: @transaction.receiver.email
      },
      amount: @transaction.amount
    }
  end
end