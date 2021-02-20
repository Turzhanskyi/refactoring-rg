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
          inputs = read_account_inputs errors

          break create_account inputs if errors.empty?

          errors.each { |error| puts error }
        end

        main_menu
      end

      def load
        pp 'load'
      end

      def main_menu
        pp 'main_menu'
      end

      private

      def create_account(inputs)
        @current_account = Account.new(**inputs)
        AccountsManager.add_account @current_account
      end

      def start_commands
        @start_commands ||= %i[create load exit].each_with_object({}) do |command, obj|
          obj[I18n.t(command, scope: :COMMANDS)] = command
        end
      end
    end
  end
end
