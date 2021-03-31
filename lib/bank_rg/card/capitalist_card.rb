module BankRg
  module Card
    class CapitalistCard < BaseCard
      START_BALANCE = 100

      def initialize(account)
        super

        @balance = START_BALANCE
        @type = 'capitalist'
      end

      def put_tax(_amount)
        10
      end

      def withdraw_tax(amount)
        amount * 0.04
      end

      def send_tax(amount)
        amount * 0.1
      end
    end
  end
end
