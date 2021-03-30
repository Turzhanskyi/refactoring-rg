module BankRg
  module Console
    module AccountMenu
      def destroy_account
        puts I18n.t('common_phrases.destroy_account', **I18n.t(:y_n_answers))

        answer = gets.chomp

        return unless answer == I18n.t('y_n_answers.y')

        AccountsManager.destroy_account @current_account.login
        exit
      end
    end
  end
end
