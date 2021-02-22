module BankRg
  module Card
    class UsualCard < BaseCard
      START_BALANCE = 50
      SEND_TAX = 20

      def initialize(account)
        super

        @balance = START_BALANCE
        @type = 'usual'
      end

      def put_tax(amount)
        amount * 0.02
      end

      def withdraw_tax(amount)
        amount * 0.05
      end

      def send_tax(_amount)
        SEND_TAX
      end
    end
  end
end
