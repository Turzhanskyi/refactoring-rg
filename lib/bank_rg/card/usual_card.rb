module BankRg
  module Card
    class UsualCard < BaseCard
      def initialize
        super

        @balance = 50
        @type = 'usual'
      end

      def put_tax(amount)
        amount * 0.02
      end
    end
  end
end
