module BankRg
  class Account
    extend Validator

    LOGIN_LENGTH_RANGE = (4..20).freeze
    AGE_RANGE = (23..90).freeze
    PASSWORD_LENGTH_RANGE = (6..30).freeze

    attr_reader :login, :name, :age, :password, :card

    def initialize(login:, name:, age:, password:)
      @login = login
      @name = name
      @age = age
      @password = password
      @card = []
    end

    def create_card(type)
      @card << Card.build(type, self)
    end

    def destroy_card(number)
      @card.reject! { |card| card.number == number }
    end
  end
end
