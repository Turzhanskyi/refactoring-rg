module BankRg
  module AccountsManager
    FILE_PATH = 'accounts.yml'.freeze

    class << self
      def accounts
        File.exist?(FILE_PATH) ? YAML.load_file(FILE_PATH).to_a : []
      end

      def add_account(account)
        save_accounts(accounts << account)
      end

      def destroy_account(login)
        save_accounts(accounts.filter { |account| account.login != login })
      end

      def update_account(account_to_update)
        save_accounts(accounts.map! do |account|
          account.login == account_to_update.login ? account_to_update : account
        end)
      end

      private

      def save_accounts(accounts)
        File.open(FILE_PATH, 'w') { |f| f.write(accounts.to_yaml) }
      end
    end
  end
end
