module BankRg
  module Card
    class VirtualCard < BaseCard
      def initialize
        super

        @balance = 150
        @type = 'virtual'
      end

      def put_tax(_amount)
        1
      end
    end
  end
end
