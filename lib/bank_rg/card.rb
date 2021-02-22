module BankRg
  module Card
    class << self
      def build(type, account)
        const_get("BankRg::Card::#{type.capitalize}Card").new account
      end
    end
  end
end
