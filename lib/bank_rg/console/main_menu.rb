module BankRg
  module Console
    module MainMenu
      include CardMenu
      include AccountMenu

      def main_menu
        loop do
          puts main_menu_title

          command = main_menu_commands.key(gets.chomp)

          next puts I18n.t('error_phrases.wrong_command') if command.nil?
          break exit if command == :exit
          next public_send command if respond_to?(command, true)
        end
      end

      private

      attr_reader :current_account

      def main_menu_title
        I18n.t(:main_menu_phrases, **main_menu_commands.merge(name: current_account.name))
      end

      def main_menu_commands
        I18n.t(:main_menu_commands)
      end
    end
  end
end
