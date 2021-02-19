module BankRg
  class Account
    COMMANDS = %i[create load exit].freeze

    def console
      start_menu
    end

    def create
      pp 'create'
    end

    def load
      pp 'load'
    end

    private

    def start_menu
      %i[wellcome press_create press_load press_exit].each do |phrase|
        puts I18n.t(phrase, scope: :HELLO_PHRASES)
      end

      command = gets.chomp

      return create if commands_options[command] == :create
      return load if commands_options[command] == :load

      exit
    end

    def commands_options
      @commands_options ||= COMMANDS.each_with_object({}) do |command, obj|
        obj[I18n.t(command, scope: :COMMANDS)] = command
      end
    end
  end
end
