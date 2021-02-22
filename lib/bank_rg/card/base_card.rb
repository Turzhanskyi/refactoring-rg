module BankRg
  module Card
    CARD_NUMBER_LENGTH = 16

    class BaseCard
      attr_reader :number, :balance, :type, :account

      def initialize(account)
        @number = CARD_NUMBER_LENGTH.times.map { rand(10) }.join
        @account = account
      end

      def check_put(amount)
        return :wrong_amount if amount <= 0
        return :tax_higher if put_tax(amount) >= amount

        :ok
      end

      def put_money(amount)
        tax = put_tax(amount)

        @balance += amount - tax

        tax
      end

      def check_withdraw(amount)
        return :wrong_amount if amount <= 0
        return :not_enough_money_to_withdraw if amount + withdraw_tax(amount) > balance

        :ok
      end

      def withdraw_money(amount)
        tax = withdraw_tax(amount)

        @balance -= amount + tax

        tax
      end

      def check_send(amount)
        return :wrong_amount if amount <= 0
        return :not_enough_money_to_send if amount + send_tax(amount) > balance

        :ok
      end

      def send_money(amount)
        tax = send_tax(amount)

        @balance -= amount + tax

        tax
      end
    end
  end
end
