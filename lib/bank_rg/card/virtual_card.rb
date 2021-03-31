module BankRg
  module Card
    class VirtualCard < BaseCard
      START_BALANCE = 150

      def initialize(account)
        super

        @balance = START_BALANCE
        @type = 'virtual'
      end

      def put_tax(_amount)
        1
      end

      def withdraw_tax(amount)
        amount * 0.88
      end

      def send_tax(_amount)
        1
      end
    end
  end
end
