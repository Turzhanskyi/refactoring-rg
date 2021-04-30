class Console
  include StartMenu
  include MainMenu

  attr_reader :output_message, :current_account

  def initialize
    @output_message = OutputService.new
  end

  def call
    @current_account = acquire_current_account

    main_menu
  end
end
