module BankRg
  module Console
    module CardMenu
      def show_cards
        return puts I18n.t('ERROR_PHRASES.no_active_cards') if @current_account.card.empty?

        @current_account.card.each { |card| puts "- #{card.number}, #{card.type}" }
      end

      def create_card
        puts I18n.t(:CREATE_CARD_PHRASES, **create_card_commands.merge(exit: I18n.t(:exit)))

        type = gets_answer(create_card_commands, 'ERROR_PHRASES.wrong_card_type')

        return if type == :exit

        @current_account.create_card type
        AccountsManager.update_accounts @current_account
      end

      def destroy_card
        process_card I18n.t('COMMON_PHRASES.if_you_want_to_delete') do |number|
          puts I18n.t('COMMON_PHRASES.destroy_card', **I18n.t(:Y_N_ANSWERS).merge(card_number: number))

          break unless gets.chomp == I18n.t('Y_N_ANSWERS.y')

          @current_account.destroy_card number
          AccountsManager.update_accounts @current_account
        end
      end

      def put_money
        process_card I18n.t('COMMON_PHRASES.choose_card_putting') do |number|
          amount = gets_amount I18n.t('COMMON_PHRASES.put_amount')

          CardTransactions.put_money(number, amount)
        end
      end

      def withdraw_money
        process_card I18n.t('COMMON_PHRASES.choose_card_withdrawing') do |number|
          amount = gets_amount I18n.t('COMMON_PHRASES.withdraw_amount')

          CardTransactions.withdraw_money(number, amount)
        end
      end

      def send_money
        process_card I18n.t('COMMON_PHRASES.choose_card_sending') do |sender_number|
          puts I18n.t('COMMON_PHRASES.enter_recipient_card')

          recipient_number = gets.chomp

          if recipient_number.length != Card::CARD_NUMBER_LENGTH
            break puts I18n.t('ERROR_PHRASES.wrong_card_number_length')
          end

          amount = gets_amount I18n.t('COMMON_PHRASES.send_amount')

          CardTransactions.send_money sender_number, recipient_number, amount
        end
      end

      private

      def gets_amount(phrase)
        puts phrase

        gets.chomp.to_i
      end

      def gets_answer(options, wrong_answer_error)
        loop do
          answer = gets.chomp

          return :exit if answer == I18n.t(:exit)

          answer = options.key(answer)
          next puts I18n.t(wrong_answer_error) if answer.nil?

          return answer
        end
      end

      def process_card(title_phrase)
        return puts I18n.t('ERROR_PHRASES.no_active_cards') if @current_account.card.empty?

        number = gets_answer(print_cards(title_phrase), 'ERROR_PHRASES.wrong_number')

        return if number == :exit

        yield number
      end

      def print_cards(title_phrase)
        puts title_phrase

        cards_numbers = {}

        @current_account.card.each.with_index(1) do |card, index|
          puts "- #{card.number}, #{card.type}, press #{index}"
          cards_numbers[card.number] = index.to_s
        end

        puts I18n.t(:PRESS_EXIT_PHRASE, **{ exit: I18n.t(:exit) })

        cards_numbers
      end

      def create_card_commands
        @create_card_commands ||= I18n.t(:CREATE_CARD_COMMANDS)
      end
    end
  end
end
