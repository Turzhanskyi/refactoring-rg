class VirtualCard < BaseCard
  START_BALANCE = 150.00

  def initialize(account)
    super

    @type = 'virtual'
    @balance = START_BALANCE
  end

  private

  def withdraw_percent
    88
  end

  def put_fixed
    1
  end

  def sender_fixed
    1
  end
end
