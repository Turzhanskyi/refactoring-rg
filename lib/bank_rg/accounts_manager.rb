module BankRg
  module AccountsManager
    FILE_PATH = 'accounts.yml'.freeze

    class << self
      def accounts?
        !accounts.empty?
      end

      def find_account(login, password)
        accounts.find { |account| account.login == login && account.password == password }
      end

      def exists?(login)
        accounts.map(&:login).include? login
      end

      def add_account(account)
        save_accounts(accounts << account)
      end

      def destroy_account(login)
        save_accounts(accounts.filter { |account| account.login != login })
      end

      def update_accounts(*accounts_to_update)
        accounts_to_update.uniq!

        save_accounts(accounts.map! do |account|
          accounts_to_update.detect { |account_to_update| account_to_update.login == account.login } || account
        end)
      end

      def find_card(number)
        accounts.flat_map(&:card).detect { |card| card.number == number }
      end

      private

      def accounts
        @accounts ||= File.exist?(FILE_PATH) ? YAML.load_file(FILE_PATH).to_a : []
      end

      def save_accounts(accounts)
        File.open(FILE_PATH, 'w') { |f| f.write(accounts.to_yaml) }

        @accounts = nil
      end
    end
  end
end
