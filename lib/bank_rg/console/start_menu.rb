module BankRg
  module Console
    module StartMenu
      include AccountInputsReader

      def acquire_current_account
        puts I18n.t(:START_MENU_PHRASES, **start_menu_commands)

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
          accounts = AccountsManager.accounts

          return create_the_first_account if accounts.empty?

          login = login_input
          password = password_input

          found = accounts.find { |account| account.login == login && account.password == password }

          return found unless found.nil?

          puts I18n.t(:user_not_exists, scope: :ERROR_PHRASES)
        end
      end

      def create_the_first_account
        puts I18n.t('COMMON_PHRASES.create_first_account', **I18n.t(:Y_N_ANSWERS))

        gets.chomp == I18n.t('Y_N_ANSWERS.y') ? create : acquire_current_account
      end

      private

      def start_menu_commands
        @start_menu_commands ||= I18n.t(:START_MENU_COMMANDS)
      end
    end
  end
end
