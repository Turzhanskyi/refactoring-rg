module BankRg
  module Console
    class << self
      include StartMenu
      include MainMenu

      def call
        @current_account = acquire_current_account

        main_menu
      end
    end
  end
end
