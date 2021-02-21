module BankRg
  module Card
    class << self
      def build(type)
        const_get("BankRg::Card::#{type.capitalize}Card").new
      end
    end
  end
end
