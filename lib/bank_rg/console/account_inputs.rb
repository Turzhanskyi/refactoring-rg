module BankRg
  module Console
    module AccountInputs
      def account_inputs(errors)
        {
          name: name_input(errors),
          age: age_input(errors),
          login: login_input(errors),
          password: password_input(errors)
        }
      end

      def name_input(errors = [])
        puts I18n.t(:name, scope: :ask_phrases)

        Account.validate_name gets.chomp, errors
      end

      def age_input(errors = [])
        puts I18n.t(:age, scope: :ask_phrases)

        Account.validate_age gets.chomp.to_i, errors
      end

      def login_input(errors = [])
        puts I18n.t(:login, scope: :ask_phrases)

        Account.validate_login gets.chomp, errors
      end

      def password_input(errors = [])
        puts I18n.t(:password, scope: :ask_phrases)

        Account.validate_password gets.chomp, errors
      end
    end
  end
end
