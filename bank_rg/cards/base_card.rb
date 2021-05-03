class BaseCard
  attr_reader :number, :balance, :type, :account

  CARD_NUMBER_LENGTH = 16

  def initialize(account)
    @account = account
    @number = generate_card_number
  end

  def withdraw_tax(amount)
    tax(amount, withdraw_percent, withdraw_fixed)
  end

  def put_tax(amount)
    tax(amount, put_percent, put_fixed)
  end

  def sender_tax(amount)
    tax(amount, sender_percent, sender_fixed)
  end

  def put_money(amount)
    @balance += amount - put_tax(amount)
    AccountManager.update(account)
  end

  def withdraw_money(amount)
    @balance -= amount - withdraw_tax(amount)
    AccountManager.update(account)
  end

  def send_money(amount, recipient_card)
    @balance -= amount - sender_tax(amount)
    recipient_card.put_money amount
    AccountManager.update(account)
  end

  def enough_money_for_put?(amount)
    (balance + amount - put_tax(amount)).positive?
  end

  def enough_money_for_withdraw?(amount)
    (balance - amount - withdraw_tax(amount)).positive?
  end

  def enough_money_for_send?(amount)
    (balance - amount - sender_tax(amount)).positive?
  end

  private

  def generate_card_number
    CARD_NUMBER_LENGTH.times.map { rand(10) }.join
  end

  def tax(amount, percent, fixed)
    amount * percent / 100.0 + fixed
  end

  def withdraw_percent
    0
  end

  def withdraw_fixed
    0
  end

  def put_percent
    0
  end

  def put_fixed
    0
  end

  def sender_percent
    0
  end

  def sender_fixed
    0
  end
end
