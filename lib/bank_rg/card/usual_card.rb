module BankRg
  module Card
    class UsualCard < BaseCard
      START_BALANCE = 50

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
        20
      end
    end
  end
end
