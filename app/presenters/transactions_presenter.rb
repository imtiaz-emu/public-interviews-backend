# return json list of all transactions
class TransactionsPresenter
  def initialize(transactions)
    @transactions = transactions
  end

  def as_json
    @transactions.map do |transaction|
      {
        id: transaction.id,
        sender: {
          phone: transaction.sender.phone_number,
          email: transaction.sender.email
        },
        receiver: {
          phone: transaction.receiver.phone_number,
          email: transaction.receiver.email
        },
        amount: transaction.amount
      }
    end
  end
end