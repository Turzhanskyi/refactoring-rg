class CapitalistCard < BaseCard
  START_BALANCE = 100.00

  def initialize(account)
    super

    @type = 'capitalist'
    @balance = START_BALANCE
  end

  private

  def withdraw_percent
    4
  end

  def put_fixed
    10
  end

  def sender_percent
    10
  end
end
