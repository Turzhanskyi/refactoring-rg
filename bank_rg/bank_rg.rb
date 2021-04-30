require 'yaml'
require 'pry'
require 'i18n'

require_relative '../config/i18n'

require_relative 'modules/start_menu'
require_relative 'modules/card_management'
require_relative 'modules/card_transaction'
require_relative 'modules/main_menu'

require_relative 'console/account_manager'
require_relative 'console/account'
require_relative 'cards/base_card'
require_relative 'cards/capitalist_card'
require_relative 'cards/usual_card'
require_relative 'cards/virtual_card'
require_relative 'console/console'
require_relative 'console/storage'

require_relative 'services/output_service'
