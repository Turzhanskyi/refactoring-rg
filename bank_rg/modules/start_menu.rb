module StartMenu
  CREATE_COMMAND = I18n.t('commands.create')
  LOAD_COMMAND = I18n.t('commands.load')

  def acquire_current_account
    output_message.introduction
    action = gets.chomp
    return create if action == CREATE_COMMAND
    return load if action == LOAD_COMMAND

    exit
  end

  def create
    loop do
      account = Account.new(name: input(I18n.t('enter_name')),
                            age: input(I18n.t('enter_age')).to_i,
                            login: input(I18n.t('enter_login')),
                            password: input(I18n.t('enter_password')))
      next show_errors(account.errors) unless account.valid?

      AccountManager.add(account)
      return account
    end
  end

  def load
    loop do
      return create_the_first_account unless AccountManager.accounts?

      login = input(I18n.t('enter_login'))
      password = input(I18n.t('enter_password'))
      return AccountManager.find_by_login(login) if AccountManager.exists?(login, password)

      next output_message.no_account
    end
  end

  def create_the_first_account
    output_message.offer_create_first_account
    gets.chomp == MainMenu::YES_ANSWER ? create : call
  end

  private

  def input(message)
    puts(message)
    gets.chomp
  end

  def show_errors(errors)
    errors.each { |error| puts error }
    errors.clear
  end
end
