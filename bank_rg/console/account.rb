class Account
  attr_reader :login, :name, :age, :password, :cards, :errors

  LOGIN_LENGTH = (4..20).freeze
  AGE_RANGE = (23..90).freeze
  PASSWORD_LENGTH = (6..30).freeze

  def initialize(login:, name:, age:, password:)
    @login = login
    @name = name
    @age = age
    @password = password
    @cards = []
    @errors = []
  end

  def add_card(card_type)
    cards << Object.const_get("#{card_type.capitalize}Card").new(self)
    AccountManager.update(self)
  end

  def destroy_card(card_index)
    cards.delete_at(card_index.to_i - 1)
    AccountManager.update(self)
  end

  def destroy
    new_accounts = Storage.load_accounts.delete_if { |account| account.login == login }
    Storage.save(new_accounts)
    exit
  end

  def valid?
    validate!
    errors.empty?
  end

  private

  def validate!
    validate_name
    validate_login
    validate_password
    validate_age
  end

  def validate_name
    errors << I18n.t('errors.name.first_upcase_letter') if name.strip.empty? || first_letter_upcase?
  end

  def validate_login
    errors << I18n.t('errors.login.not_empty') if login.strip.empty?
    errors << I18n.t('errors.login.longer_than', min_length: LOGIN_LENGTH.min) if login.length < LOGIN_LENGTH.min
    errors << I18n.t('errors.login.shorter_than', max_length: LOGIN_LENGTH.max) if login.length > LOGIN_LENGTH.max
    errors << I18n.t('errors.login.account_exists') if AccountManager.exists_with_login?(login)
  end

  def validate_password
    errors << I18n.t('errors.password.not_empty') if password.strip.empty?
    errors << I18n.t('errors.password.longer', min: PASSWORD_LENGTH.min) if password.length < PASSWORD_LENGTH.min
    errors << I18n.t('errors.password.shorter', max: PASSWORD_LENGTH.max) if password.length > PASSWORD_LENGTH.max
  end

  def validate_age
    errors << I18n.t('errors.age.range', min: AGE_RANGE.min, max: AGE_RANGE.max) unless AGE_RANGE.include?(age)
  end

  def first_letter_upcase?
    name[0].upcase != name[0]
  end
end
