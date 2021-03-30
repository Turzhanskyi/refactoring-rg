module BankRg
  module Console
    module CardTransactions
      class << self
        def put_money(number, amount)
          card = AccountsManager.find_card(number)

          return unless pass_check?(card, :check_put, amount)

          perform_operation(card, :put_money, amount, 'common_phrases.money_was_put')

          AccountsManager.update_accounts card.account
        end

        def withdraw_money(number, amount)
          card = AccountsManager.find_card(number)

          return unless pass_check?(card, :check_withdraw, amount)

          perform_operation(card, :withdraw_money, amount, 'common_phrases.money_was_withdraw')

          AccountsManager.update_accounts card.account
        end

        def send_money(sender_number, recipient_number, amount)
          sender_card = AccountsManager.find_card(sender_number)
          recipient_card = AccountsManager.find_card(recipient_number)

          return print_error(:no_card_with_number, recipient_number) if recipient_card.nil?

          return if !pass_check?(sender_card, :check_send, amount) || !pass_check?(recipient_card, :check_put, amount)

          perform_operation(sender_card, :send_money, amount, 'common_phrases.money_was_sent')
          perform_operation(recipient_card, :put_money, amount, 'common_phrases.money_was_put')

          AccountsManager.update_accounts sender_card.account, recipient_card.account
        end

       private

        ERRORS = {
          wrong_amount: 'error_phrases.wrong_amount',
          tax_higher: 'error_phrases.tax_higher',
          not_enough_money_to_withdraw: 'error_phrases.not_enough_money_to_withdraw',
          no_card_with_number: 'error_phrases.no_card_with_number',
          not_enough_money_to_send: 'error_phrases.not_enough_money_to_send'
        }.freeze

        def perform_operation(card, operation, amount, result_message)
          tax = card.send(operation, amount)

          puts I18n.t(result_message, **{ amount: amount, number: card.number, balance: card.balance, tax: tax })
        end

        def pass_check?(card, check, amount)
          status = card.send(check, amount)

          return true if status == :ok

          print_error status

          false
        end

        def print_error(error, *params)
          puts I18n.t(ERRORS.dig(error), params)
        end
     end
    end
  end
end
