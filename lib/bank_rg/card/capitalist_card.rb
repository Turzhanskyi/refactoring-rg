module BankRg
  module Card
    class CapitalistCard < BaseCard
      START_BALANCE = 100
      PUT_TAX = 10

      def initialize(account)
        super

        @balance = START_BALANCE
        @type = 'capitalist'
      end

      def put_tax(_amount)
        PUT_TAX
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
