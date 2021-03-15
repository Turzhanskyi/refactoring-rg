module BankRg
  class Account
    module Validator
      def validate_name(name, errors)
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.name.first_letter') if name == '' || name[0] != name[0].upcase

        name
      end

      def validate_login(login, errors)
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.login.present') if login == ''
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.login.longer') if login.length < LOGIN_LENGTH_RANGE.first
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.login.shorter') if login.length > LOGIN_LENGTH_RANGE.last
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.login.exists') if AccountsManager.exists?(login)

        login
      end

      def validate_age(age, errors)
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.age.length') unless AGE_RANGE.include? age

        age
      end

      def validate_password(password, errors)
        errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.password.present') if password == ''
        if password.length < PASSWORD_LENGTH_RANGE.first
          errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.password.longer')
        end
        if password.length > PASSWORD_LENGTH_RANGE.last
          errors.push I18n.t('ACCOUNT_VALIDATION_PHRASES.password.shorter')
        end

        password
      end
    end
  end
end
