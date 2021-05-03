class OutputService
  def introduction
    I18n.t('introduction').each_value { |message| puts message }
  end

  def no_account
    puts I18n.t('no_account')
  end

  def offer_create_first_account
    puts I18n.t('first_account')
  end

  def wrong_command
    puts I18n.t('main_menu_commands.wrong_command')
  end

  def greeting(name)
    I18n.t('main_menu', deep_interpolation: true, name: name).each_value { |message| puts message }
  end

  def destroy_account
    puts I18n.t('destroy_account')
  end

  def no_cards
    puts I18n.t('no_cards')
  end

  def cards_description
    I18n.t('create_card').each_value { |message| puts message }
  end

  def wrong_card_type
    puts I18n.t('wrong_card_type')
  end

  def wrong_number(operation)
    puts I18n.t("#{operation}.wrong_number")
  end

  def confirm_destroying_card(card_number)
    puts I18n.t('destroy_card.confirm_destroying', card_number: card_number)
  end

  def prompt_input_amount(operation)
    puts I18n.t("#{operation}.prompt_input_amount")
  end

  def money_put(amount, card)
    puts I18n.t('put_money.result',
                amount: amount, number: card.number,
                balance: card.balance, tax: card.put_tax(amount))
  end

  def money_withdraw(amount, card)
    puts I18n.t('withdraw_money.result',
                amount: amount, number: card.number,
                balance: card.balance, tax: card.withdraw_tax(amount))
  end

  def money_send(amount, card, recipient_card)
    puts I18n.t('send_money.result',
                amount: amount, number: recipient_card.number,
                balance: recipient_card.balance, tax: recipient_card.put_tax(amount))
    puts I18n.t('send_money.result',
                amount: amount, number: card.number,
                balance: card.balance, tax: card.sender_tax(amount))
  end

  def enter_recipient_card
    puts I18n.t('send_money.enter_recipient_card')
  end

  def tax_is_higher(operation)
    puts I18n.t "#{operation}.tax_is_higher"
  end

  def no_enough_money(operation)
    puts I18n.t("#{operation}.no_enough_money")
  end

  def incorrect_card
    puts I18n.t('send_money.input_correct_card')
  end

  def no_recipient_card(recipient_number)
    puts I18n.t('send_money.no_recipient_card', number: recipient_number)
  end

  def incorrect_amount(operation)
    puts I18n.t("#{operation}.incorrect_amount")
  end

  def show_cards_list(cards, message)
    puts message
    cards.each.with_index(1) do |card, index|
      puts I18n.t(:cards_list, number: card.number, type: card.type, index: index)
    end
    prompt_exit
  end

  def prompt_exit
    puts I18n.t('prompt_exit')
  end
end
