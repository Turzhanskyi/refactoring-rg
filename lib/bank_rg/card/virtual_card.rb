module BankRg
  module Card
    class VirtualCard < BaseCard
      START_BALANCE = 150
      PUT_TAX = 1
      SEND_TAX = 1

      def initialize(account)
        super

        @balance = START_BALANCE
        @type = 'virtual'
      end

      def put_tax(_amount)
        PUT_TAX
      end

      def withdraw_tax(amount)
        amount * 0.88
      end

      def send_tax(_amount)
        SEND_TAX
      end
    end
  end
end
