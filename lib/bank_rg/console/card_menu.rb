module BankRg
  module Console
    module CardMenu
      def show_cards
        return print_error('ERROR_PHRASES.no_active_cards') unless active_cards?

        @current_account.card.each { |card| puts "- #{card.number}, #{card.type}" }
      end

      def create_card
        loop do
          create_card_title

          type = create_card_commands.key(gets.chomp)

          break if type == I18n.t(:exit)
          next print_error('ERROR_PHRASES.wrong_card_type') if type.nil?

          @current_account.create_card type
          AccountsManager.update_account @current_account

          break
        end
      end

      def destroy_card
        process_card I18n.t('COMMON_PHRASES.if_you_want_to_delete') do |card|
          puts I18n.t('COMMON_PHRASES.destroy_card', **I18n.t(:Y_N_ANSWERS).merge(card_number: card.number))

          answer = gets.chomp

          break unless answer == I18n.t('Y_N_ANSWERS.y')

          @current_account.destroy_card card.number
          AccountsManager.update_account @current_account

          break
        end
      end

      def put_money
        process_card I18n.t('COMMON_PHRASES.choose_card_putting') do |card|
          puts I18n.t('COMMON_PHRASES.input_amount')

          amount = gets.chomp.to_i

          break print_error('ERROR_PHRASES.correct_amount') if amount <= 0
          break print_error('ERROR_PHRASES.tax_higher') if card.put_tax(amount) >= amount

          card.put_money amount
          AccountsManager.update_account @current_account

          break print_money_was_put card, amount
        end
      end

      # def send_money
      #   process_card I18n.t('COMMON_PHRASES.choose_card_sending') do |sender_card|
      #     recipient_card = gets_recipient_card

      #     break if recipient_card.nil?

      #     break send_from_to(sender_card, recipient_card)
      #   end
      # end

      private

      # def send_from_to(sender_card, recipient_card)
      #   puts 'Input the amount of money you want to withdraw'

      #   amount = gets.chomp.to_i

      #   return print_error('ERROR_PHRASES.correct_amount') if amount <= 0

      #   sender_balance = sender_card.balance - amount - sender_card.sender_tax(amount)

      #   return puts "You don't have enough money on card for such operation" if sender_balance < 0
      #   return puts 'There is no enough money on sender card' if recipient_card.tax(amount) >= ampunt

      # end

      # def gets_recipient_card
      #   puts I18n.t('COMMON_PHRASES.enter_recipient_card')

      #   number = gets.chomp

      #   return puts 'Please, input correct number of card' if number.length != 16

      #   found_card = AccountsManager.accounts.flat_map(&:card).detect { |card| card.number == number }

      #   return puts "There is no card with number #{number}\n" if found_card.nil?

      #   found_card
      # end

      def process_card(title_phrase, &block)
        return print_error('ERROR_PHRASES.no_active_cards') unless active_cards?

        loop do
          print_cards title_phrase

          answer = gets.chomp

          break if answer == I18n.t(:exit)

          card = dig_card(answer.to_i - 1)

          next print_error('ERROR_PHRASES.wrong_number') if card.nil?

          block.call(card)
        end
      end

      def print_cards(title_phrase)
        puts title_phrase

        @current_account.card.each.with_index(1) do |card, index|
          puts "- #{card.number}, #{card.type}, press #{index}"
        end

        puts I18n.t(:PRESS_EXIT_PHRASE, **{ exit: I18n.t(:exit) })
      end

      def dig_card(index)
        return nil if index.negative?

        @current_account.card[index]
      end

      def active_cards?
        !@current_account.card.empty?
      end

      def create_card_title
        puts I18n.t(:CREATE_CARD_PHRASES, **create_card_commands.merge(exit: I18n.t(:exit)))
      end

      def create_card_commands
        @create_card_commands ||= I18n.t(:CREATE_CARD_COMMANDS)
      end

      def print_error(error)
        puts I18n.t error
      end

      def print_money_was_put(card, amount)
        puts I18n.t('COMMON_PHRASES.money_was_put', **{
                      money: amount,
                      number: card.number,
                      balance: card.balance,
                      tax: card.put_tax(amount)
                    })
      end
    end
  end
end
