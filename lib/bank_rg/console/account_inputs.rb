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
        puts I18n.t(:name, scope: :ASK_PHRASES)

        Account.validate_name gets.chomp, errors
      end

      def age_input(errors = [])
        puts I18n.t(:age, scope: :ASK_PHRASES)

        Account.validate_age gets.chomp.to_i, errors
      end

      def login_input(errors = [])
        puts I18n.t(:login, scope: :ASK_PHRASES)

        Account.validate_login gets.chomp, errors
      end

      def password_input(errors = [])
        puts I18n.t(:password, scope: :ASK_PHRASES)

        Account.validate_password gets.chomp, errors
      end
    end
  end
end
