class AccountManager
  class << self
    def accounts?
      accounts.any?
    end

    def exists?(login, password)
      accounts.any? { |account| account.login == login && account.password == password }
    end

    def exists_with_login?(login)
      accounts.any? { |account| account.login == login }
    end

    def find_by_login(login)
      accounts.find { |account| account.login == login }
    end

    def add(account)
      Storage.save(accounts << account)
    end

    def update(account_to_update)
      new_accounts = accounts.map { |account| account.login == account_to_update.login ? account_to_update : account }
      Storage.save(new_accounts)
    end

    def find_card(number)
      all_cards.find { |card| card.number == number }
    end

    private

    def accounts
      Storage.load_accounts
    end

    def all_cards
      accounts.flat_map(&:cards)
    end
  end
end
