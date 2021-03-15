module BankRg
  module Console
    module MainMenu
      include CardMenu
      include AccountMenu

      def main_menu
        loop do
          puts main_menu_title

          command = main_menu_commands.key(gets.chomp)

          next puts I18n.t('ERROR_PHRASES.wrong_command') if command.nil?
          break exit if command == :exit
          next send command if respond_to?(command, true)
        end
      end

      private

      attr_reader :current_account

      def main_menu_title
        I18n.t(:MAIN_MENU_PHRASES, **main_menu_commands.merge(name: current_account.name))
      end

      def main_menu_commands
        I18n.t(:MAIN_MENU_COMMANDS)
      end
    end
  end
end
