module BankRg
  class Account
    class << self
      def validate_name(name, errors)
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.name.first_letter') if name == '' || name[0] != name[0].upcase

        name
      end

      def validate_login(login, errors)
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.login.present') if login == ''
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.login.longer') if login.length < 4
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.login.shorter') if login.length > 20
        if AccountsManager.accounts.map(&:login).include? login
          errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.login.exists')
        end

        login
      end

      def validate_age(age, errors)
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.age.length') if age < 23 || age > 90

        age
      end

      def validate_password(password, errors)
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.password.present') if password == ''
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.password.longer') if password.length < 6
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.password.shorter') if password.length > 30

        password
      end
    end

    attr_reader :login, :name, :age, :password, :card

    def initialize(login:, name:, age:, password:)
      @login = login
      @name = name
      @age = age
      @password = password
      @card = []
    end

    def create_card(type)
      @card << Card.build(type)
    end

    def destroy_card(number)
      @card.reject! { |card| card.number == number }
    end
  end
end
