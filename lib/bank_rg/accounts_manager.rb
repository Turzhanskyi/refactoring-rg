module BankRg
  module AccountsManager
    FILE_PATH = 'accounts.yml'.freeze

    class << self
      def accounts
        File.exist?(FILE_PATH) ? YAML.load_file(FILE_PATH).to_a : []
      end

      def add_account(account)
        new_account = accounts << account
        File.open(FILE_PATH, 'w') { |f| f.write(new_account.to_yaml) }
      end
    end
  end
end
