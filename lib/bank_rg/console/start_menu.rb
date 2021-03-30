module BankRg
  module Console
    module StartMenu
      include AccountInputs

      def acquire_current_account
        puts I18n.t(:start_menu_phrases, **start_menu_commands)

        command = gets.chomp

        return create if start_menu_commands.key(command) == :create
        return load if start_menu_commands.key(command) == :load

        exit
      end

      def create
        loop do
          errors = []
          inputs = account_inputs errors

          next errors.each { |error| puts error } unless errors.empty?

          account = Account.new(**inputs)
          AccountsManager.add_account account
          return account
        end
      end

      def load
        loop do
          return create_the_first_account unless AccountsManager.accounts?

          login = login_input
          password = password_input

          account = AccountsManager.find_account(login, password)

          return account unless account.nil?

          puts I18n.t(:user_not_exists, scope: :error_phrases)
        end
      end

      def create_the_first_account
        puts I18n.t('common_phrases.create_first_account', **I18n.t(:y_n_answers))

        gets.chomp == I18n.t('y_n_answers.y') ? create : acquire_current_account
      end

      private

      def start_menu_commands
        @start_menu_commands ||= I18n.t(:start_menu_commands)
      end
    end
  end
end
