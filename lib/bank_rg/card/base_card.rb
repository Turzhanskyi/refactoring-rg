module BankRg
  module Card
    class BaseCard
      attr_reader :number, :balance, :type

      def initialize
        @number = 16.times.map { rand(10) }.join
      end

      def put_money(amount)
        @balance += amount - put_tax(amount)
      end
    end
  end
end
