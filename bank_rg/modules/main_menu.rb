module MainMenu
  include CardManagement
  include CardTransaction

  EXIT_COMMAND = I18n.t('commands.exit')
  YES_ANSWER = I18n.t('answers.agree')
  MAIN_MENU_COMMANDS = {
    'SC' => 'show_cards',
    'CC' => 'create_card',
    'DC' => 'destroy_card',
    'PM' => 'put_money',
    'WM' => 'withdraw_money',
    'SM' => 'send_money',
    'DA' => 'destroy_account'
  }.freeze

  def main_menu
    loop do
      command = command_input
      break exit if command == EXIT_COMMAND
      next output_message.wrong_command unless MAIN_MENU_COMMANDS.keys.include?(command)

      next public_send MAIN_MENU_COMMANDS[command]
    end
  end

  private

  def command_input
    output_message.greeting(current_account.name)
    gets.chomp
  end
end
