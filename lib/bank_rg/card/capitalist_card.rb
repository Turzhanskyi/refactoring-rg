module BankRg
  module Card
    class CapitalistCard < BaseCard
      def initialize
        super

        @balance = 100
        @type = 'capitalist'
      end

      def put_tax(_amount)
        10
      end
    end
  end
end
