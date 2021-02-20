module BankRg
  module Console
    class << self
      include AccountInputsReader

      def call
        %i[wellcome press_create press_load press_exit].each do |phrase|
          puts I18n.t(phrase, scope: :HELLO_PHRASES)
        end

        command = gets.chomp

        return create if start_commands[command] == :create
        return load if start_commands[command] == :load

        exit
      end

      def create
        loop do
          errors = []
          inputs = account_inputs errors

          next errors.each { |error| puts error } unless errors.empty?

          @current_account = Account.new(**inputs)
          AccountsManager.add_account @current_account

          break
        end

        main_menu
      end

      def load
        loop do
          accounts = AccountsManager.accounts

          return create_the_first_account if accounts.empty?

          login = login_input
          password = password_input

          @current_account = accounts.find { |account| account.login == login && account.password == password }

          break unless @current_account.nil?

          puts I18n.t(:user_not_exists, scope: :ERROR_PHRASES)
        end

        main_menu
      end

      def main_menu
        pp 'main_menu'
      end

      def create_the_first_account
        puts I18n.t(:create_first_account, scope: :COMMON_PHRASES)

        gets.chomp == 'y' ? create : start
      end

      private

      def start_commands
        @start_commands ||= %i[create load exit].each_with_object({}) do |command, obj|
          obj[I18n.t(command, scope: :COMMANDS)] = command
        end
      end
    end
  end
end
