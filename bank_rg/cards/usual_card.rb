class UsualCard < BaseCard
  START_BALANCE = 50.00

  def initialize(account)
    super

    @type = 'usual'
    @balance = START_BALANCE
  end

  private

  def withdraw_percent
    5
  end

  def put_percent
    2
  end

  def sender_fixed
    20
  end
end
