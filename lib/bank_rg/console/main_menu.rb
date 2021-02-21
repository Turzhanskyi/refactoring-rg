module BankRg
  module Console
    module MainMenu
      def main_menu
        loop do
          puts main_menu_title

          command = main_menu_commands.key(gets.chomp)

          next puts I18n.t('ERROR_PHRASES.wrong_command') if command.nil?
          break exit if command == :exit
          next send command if respond_to?(command, true)
        end
      end

      def show_cards
        return puts I18n.t('ERROR_PHRASES.no_active_cards') if @current_account.card.empty?

        @current_account.card.each { |card| puts "- #{card.number}, #{card.type}" }
      end

      def create_card
        pp 'create card'
      end

      def destroy_card
        pp 'destroy card'
      end

      def put_money
        pp 'put money'
      end

      def withdraw_money
        pp 'withdraw money'
      end

      def send_money
        pp 'withdraw money'
      end

      def destroy_account
        puts I18n.t('COMMON_PHRASES.destroy_account')

        answer = gets.chomp

        return unless answer == 'y'

        AccountsManager.destroy_account @current_account.login
        exit
      end

      private

      def main_menu_title
        I18n.t(:MAIN_MENU_PHRASES, **main_menu_commands.merge(name: @current_account.name))
      end

      def main_menu_commands
        @main_menu_commands ||= I18n.t(:MAIN_MENU_COMMANDS)
      end
    end
  end
end
