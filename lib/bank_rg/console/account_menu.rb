module BankRg
  module Console
    module AccountMenu
      def destroy_account
        puts I18n.t('COMMON_PHRASES.destroy_account', **I18n.t(:Y_N_ANSWERS))

        answer = gets.chomp

        return unless answer == I18n.t('Y_N_ANSWERS.y')

        AccountsManager.destroy_account @current_account.login
        exit
      end
    end
  end
end
