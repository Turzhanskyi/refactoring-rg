RSpec.describe Console do
  OVERRIDABLE_FILENAME = 'spec/fixtures/account.yml'.freeze

  ASK_PHRASES = {
    name: I18n.t('enter_name'),
    login: I18n.t('enter_login'),
    password: I18n.t('enter_password'),
    age: I18n.t('enter_age')
  }.freeze

  MAIN_OPERATIONS_TEXTS = [
    I18n.t('main_menu.prompt_commands'),
    I18n.t('main_menu.prompt_show_cards'),
    I18n.t('main_menu.prompt_create_card'),
    I18n.t('main_menu.prompt_destroy_card'),
    I18n.t('main_menu.prompt_put_money'),
    I18n.t('main_menu.prompt_withdraw_money'),
    I18n.t('main_menu.prompt_send_money'),
    I18n.t('main_menu.prompt_destroy_account'),
    I18n.t('main_menu.prompt_exit')
  ].freeze

  CARDS = {
    usual: {
      type: 'usual',
      balance: 50.00
    },
    capitalist: {
      type: 'capitalist',
      balance: 100.00
    },
    virtual: {
      type: 'virtual',
      balance: 150.00
    }
  }.freeze

  let(:name) { 'Vitalii' }
  let(:age) { 43 }
  let(:login) { 'Vitalii' }
  let(:password) { '123456' }
  let(:current_account) { Account.new(name: name, age: age, login: login, password: password) }
  let(:current_subject) { described_class.new }

  describe '#call' do
    context 'when correct method calling' do
      before { allow(current_subject).to receive(:main_menu) }

      after { current_subject.call }

      it 'create account if input is create' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { I18n.t('commands.create') }
        expect(current_subject).to receive(:create)
      end

      it 'load account if input is load' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { I18n.t('commands.load') }
        expect(current_subject).to receive(:load)
      end

      it 'leave app if input is exit or some another word' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'another' }
        expect(current_subject).to receive(:exit)
      end
    end

    context 'with correct out' do
      it do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'test' }
        allow(current_subject).to receive(:exit)
        allow(current_subject).to receive(:main_menu)
        I18n.t('introduction').each_value { |phrase| expect(current_subject.output_message).to receive(:puts).with(phrase) }
        current_subject.call
      end
    end
  end

  describe '#create' do
    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }
    let(:success_inputs) { [success_name_input, success_age_input, success_login_input, success_password_input] }

    context 'with success result' do
      before do
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*success_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(AccountManager).to receive(:accounts).and_return([])
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      it 'with correct out' do
        allow(File).to receive(:open)
        ASK_PHRASES.values.each { |phrase| expect(current_subject).to receive(:puts).with(phrase) }
        I18n.t('errors').values.map(&:values).each do |phrase|
          expect(current_subject).not_to receive(:puts).with(phrase)
        end
        current_subject.create
      end

      it 'write to file Account instance' do
        stub_const('Storage::FILE_PATH', OVERRIDABLE_FILENAME)
        current_subject.create
        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a Account }
      end
    end

    context 'with errors' do
      before do
        all_inputs = current_inputs + success_inputs
        allow(File).to receive(:open)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(AccountManager).to receive(:accounts).and_return([])
      end

      context 'with name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:error) { I18n.t('errors.name.first_upcase_letter') }
          let(:current_inputs) { [error_input, success_age_input, success_login_input, success_password_input] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with login errors' do
        let(:current_inputs) { [success_name_input, success_age_input, error_input, success_password_input] }

        context 'when present' do
          let(:error_input) { '' }
          let(:error) { I18n.t('errors.login.not_empty') }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { I18n.t('errors.login.longer_than', min_length: Account::LOGIN_LENGTH.first) }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { I18n.t('errors.login.shorter_than', max_length: Account::LOGIN_LENGTH.last) }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when exists' do
          let(:error_input) { 'Denis1345' }
          let(:error) { I18n.t('errors.login.account_exists') }

          before do
            allow(AccountManager).to receive(:accounts) { [instance_double('Account', login: error_input)] }
          end

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with age errors' do
        let(:current_inputs) { [success_name_input, error_input, success_login_input, success_password_input] }
        let(:error) { I18n.t('errors.age.range', min: Account::AGE_RANGE.first, max: Account::AGE_RANGE.last) }

        context 'with length minimum' do
          let(:error_input) { '22' }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'with length maximum' do
          let(:error_input) { '91' }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with password errors' do
        let(:current_inputs) { [success_name_input, success_age_input, success_login_input, error_input] }

        context 'when absent' do
          let(:error_input) { '' }
          let(:error) { I18n.t('errors.password.not_empty') }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { I18n.t('errors.password.longer', min: Account::PASSWORD_LENGTH.first) }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { I18n.t('errors.password.shorter', max: Account::PASSWORD_LENGTH.last) }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end
    end
  end

  describe '#load' do
    context 'without active accounts' do
      it do
        expect(AccountManager).to receive(:accounts).and_return([])
        expect(current_subject).to receive(:create_the_first_account).and_return([])
        current_subject.load
      end
    end

    context 'with active accounts' do
      before do
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(AccountManager).to receive(:accounts) { [instance_double('Account', login: login, password: password)] }
      end

      context 'with correct out' do
        let(:all_inputs) { [login, password] }

        it do
          [ASK_PHRASES[:login], ASK_PHRASES[:password]].each do |phrase|
            expect(current_subject).to receive(:puts).with(phrase)
          end
          current_subject.load
        end
      end

      context 'when account exists' do
        let(:all_inputs) { [login, password] }

        it do
          expect { current_subject.load }.not_to output(I18n.t(:no_account)).to_stdout
        end
      end

      context 'when account doesn\t exists' do
        let(:all_inputs) { ['test', 'test', login, password] }

        it do
          expect { current_subject.load }.to output(/#{I18n.t('no_account')}/).to_stdout
        end
      end
    end
  end

  describe '#create_the_first_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }

    it 'with correct out' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) {}
      expect(current_subject).to receive(:call)
      expect { current_subject.create_the_first_account }.to output("#{I18n.t('first_account')}\n").to_stdout
    end

    it 'calls create if user inputs is y' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
      expect(current_subject).to receive(:create)
      current_subject.create_the_first_account
    end

    it 'calls console if user inputs is not y' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }
      expect(current_subject).to receive(:call)
      current_subject.create_the_first_account
    end
  end

  describe '#main_menu' do
    let(:name) { 'John' }
    let(:commands) do
      {
        'SC' => :show_cards,
        'CC' => :create_card,
        'DC' => :destroy_card,
        'PM' => :put_money,
        'WM' => :withdraw_money,
        'SM' => :send_money,
        'DA' => :destroy_account,
        'exit' => :exit
      }
    end

    context 'with correct out' do
      it do
        allow(current_subject).to receive(:show_cards)
        allow(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))
        expect { current_subject.main_menu }.to output(/Welcome, #{name}/).to_stdout
        MAIN_OPERATIONS_TEXTS.each do |text|
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
          expect { current_subject.main_menu }.to output(/#{text}/).to_stdout
        end
      end
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }

      it 'calls specific methods on predefined commands' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))
        allow(current_subject).to receive(:exit)

        commands.each do |command, method_name|
          expect(current_subject).to receive(method_name)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(command, 'exit')
          current_subject.main_menu
        end
      end

      it 'outputs incorrect message on undefined command' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))
        expect(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(undefined_command, 'exit')
        expect { current_subject.main_menu }.to output(/#{I18n.t('main_menu_commands.wrong_command')}/).to_stdout
      end
    end
  end

  describe '#destroy_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }
    let(:correct_account) { instance_double('Account', login: correct_login) }
    let(:fake_account) { instance_double('Account', login: fake_login) }
    let(:fake_account2) { instance_double('Account', login: fake_login2) }
    let(:accounts) { [correct_account, fake_account, fake_account2] }

    it 'with correct out' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) {}
      expect { current_subject.destroy_account }.to output("#{I18n.t('destroy_account')}\n").to_stdout
    end

    context 'when deleting' do
      before do
        stub_const('Storage::FILE_PATH', OVERRIDABLE_FILENAME)
        current_subject.instance_variable_set(:@current_account, correct_account)
      end

      it 'deletes account if user inputs is y' do
        expect(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
        allow(current_subject.current_account).to receive(:destroy)

        current_subject.destroy_account
      end

      it 'doesnt delete account' do
        expect(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }

        current_subject.destroy_account

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be false
      end
    end
  end

  describe '#show_cards' do
    let(:name) { 'Vitalii' }
    let(:age) { 23 }
    let(:login) { 'Vitalii' }
    let(:password) { 'Vitalii' }
    let(:account) { Account.new(name: name, age: age, login: login, password: password) }
    let(:card_type) { 'usual' }

    before do
      current_subject.instance_variable_set(:@current_account, account)
      current_subject.current_account.add_card(card_type)
    end

    it 'display cards if there are any' do
      card = current_subject.current_account.cards.first
      expect { current_subject.show_cards }.to output("- #{card.number}, #{card.type}\n").to_stdout
    end

    it 'outputs error if there are no active cards' do
      current_subject.instance_variable_set(:@current_account, instance_double('Account', cards: []))
      expect(current_subject.output_message).to receive(:puts).with(I18n.t('no_cards'))
      current_subject.show_cards
    end
  end

  describe '#create_card' do
    let(:name) { 'Vitalii' }
    let(:age) { 23 }
    let(:login) { 'Vitalii' }
    let(:password) { 'Vitalii' }
    let(:account) { Account.new(name: name, age: age, login: login, password: password) }

    context 'with correct out' do
      it do
        I18n.t('create_card').each_value { |phrase| expect(current_subject.output_message).to receive(:puts).with(phrase) }
        current_subject.instance_variable_set(:@current_account, account)
        current_subject.current_account.instance_variable_set(:@cards, [])
        allow(AccountManager).to receive(:accounts).and_return([])
        allow(File).to receive(:open)
        expect(current_subject).to receive_message_chain(:gets, :chomp) { 'usual' }

        current_subject.create_card
      end
    end

    context 'when correct card choose' do
      before do
        stub_const('Storage::FILE_PATH', OVERRIDABLE_FILENAME)
        current_subject.instance_variable_set(:@current_account, account)
        allow(AccountManager).to receive(:accounts) { [account] }
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      CARDS.each do |card_type, card_info|
        it "create card with #{card_type} type" do
          expect(current_subject).to receive_message_chain(:gets, :chomp) { card_info[:type] }

          current_subject.create_card

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.cards.first.type).to eq card_info[:type]
          expect(file_accounts.first.cards.first.balance).to eq card_info[:balance]
          expect(file_accounts.first.cards.first.number.length).to be 16
        end
      end
    end

    context 'when incorrect card choose' do
      it do
        current_subject.instance_variable_set(:@current_account, account)
        current_subject.current_account.instance_variable_set(:@cards, [])
        allow(File).to receive(:open)
        allow(AccountManager).to receive(:accounts).and_return([])
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')

        expect { current_subject.create_card }.to output(/#{I18n.t('wrong_card_type')}/).to_stdout
      end
    end
  end

  describe '#destroy_card' do
    context 'with cards' do
      let(:card_one) { UsualCard.new(current_account) }
      let(:card_two) { VirtualCard.new(current_account) }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct out' do
        it do
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject.current_account).to receive(:cards) { fake_cards }
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.destroy_card }.to output(/#{I18n.t('destroy_card.prompt_delete')}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = I18n.t('cards_list', number: card.number, type: card.type, index: i)
            expect { current_subject.destroy_card }.to output(message).to_stdout
          end
          current_subject.destroy_card
        end
      end

      context 'when exit if first gets is exit' do
        it do
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject.current_account).to receive(:cards) { fake_cards }
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.destroy_card }.to raise_error(SystemExit)
        end
      end

      context 'with incorrect input of card number' do
        before do
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject.current_account).to receive(:cards) { fake_cards }
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.destroy_card }.to output(/#{I18n.t('destroy_card.wrong_number')}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.destroy_card }.to output(/#{I18n.t('destroy_card.wrong_number')}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:accept_for_deleting) { 'y' }
        let(:reject_for_deleting) { 'asdf' }
        let(:deletable_card_number) { 1 }
        let(:exit) { I18n.t('commands.exit') }

        before do
          stub_const('Storage::FILE_PATH', OVERRIDABLE_FILENAME)
          allow(AccountManager).to receive(:accounts) { [current_account] }
          current_subject.instance_variable_set(:@current_account, current_account)
          current_subject.instance_variable_set(:@cards, fake_cards)
        end

        after do
          File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
        end

        it 'accept deleting' do
          commands = [deletable_card_number, accept_for_deleting, exit]
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { current_subject.destroy_card }.to change { current_account.cards.size }.by(-1)

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.card).not_to include(card_one)
        end

        it 'decline deleting' do
          commands = [deletable_card_number, reject_for_deleting]
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { current_subject.destroy_card }.not_to change(current_subject.cards, :size)
        end
      end
    end
  end

  describe '#put_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: 'Max', cards: []))
        expect { current_subject.put_money }.to output(/#{I18n.t('no_cards')}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { UsualCard.new(current_account) }
      let(:card_two) { VirtualCard.new(current_account) }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct out' do
        it do
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject.current_account).to receive(:cards) { fake_cards }
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.put_money }.to output(/#{I18n.t('put_money.choose_card')}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = I18n.t('cards_list', number: card.number, type: card.type, index: i)
            expect { current_subject.put_money }.to output(message).to_stdout
          end
          current_subject.put_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject.current_account).to receive(:cards) { fake_cards }
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.put_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(current_subject.current_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, current_account)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.put_money }.to output(/#{I18n.t('put_money.wrong_number')}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.put_money }.to output(/#{I18n.t('put_money.wrong_number')}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { CapitalistCard.new(current_account) }
        let(:card_two) { CapitalistCard.new(current_account) }
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          current_subject.instance_variable_set(:@cards, fake_cards)
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.put_money }.to output(/#{I18n.t('put_money.prompt_input_amount')}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.put_money }.to output(/#{I18n.t('put_money.incorrect_amount')}/).to_stdout
          end
        end

        context 'with amount greater then 0' do
          context 'with tax greater than amount' do
            let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

            it do
              expect { current_subject.put_money }.to output(/#{I18n.t('put_money.tax_is_higher')}/).to_stdout
            end
          end

          context 'with tax lower than amount' do
            let(:custom_cards) do
              [
                { type: 'usual', balance: balance, tax: correct_money_amount_greater_than_tax * 0.02, number: 1 },
                { type: 'capitalist', balance: balance, tax: 10, number: 1 },
                { type: 'virtual', balance: balance, tax: 1, number: 1 }
              ]
            end

            let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

            after do
              File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
            end

            it do
              custom_cards.each do |custom_card|
                allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
                allow(AccountManager).to receive(:accounts) { [current_account] }
                current_subject.current_account.instance_variable_set(:@cards, [custom_card, card_one, card_two])
                stub_const('Storage::FILE_PATH', OVERRIDABLE_FILENAME)
                new_balance = balance + correct_money_amount_greater_than_tax - custom_card[:tax]

                expect { current_subject.put_money }.to output(
                  /#{I18n.t('put_money.result', amount: correct_money_amount_greater_than_tax,
                                                number: custom_card[:number],
                                                balance: new_balance, tax: custom_card[:tax])}/
                ).to_stdout

                expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
                file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
                expect(file_accounts.first.cards.first.balance).to eq(new_balance)
              end
            end
          end
        end
      end
    end
  end

  describe '#withdraw_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', cards: []))
        expect { current_subject.withdraw_money }.to output(/#{I18n.t('no_cards')}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { UsualCard.new(current_account) }
      let(:card_two) { VirtualCard.new(current_account) }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct out' do
        it do
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject.current_account).to receive(:cards) { fake_cards }
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.withdraw_money }.to output(/#{I18n.t('withdraw_money.choose_card')}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = I18n.t(:cards_list, number: card.number, type: card.type, index: i)
            expect { current_subject.withdraw_money }.to output(message).to_stdout
          end
          current_subject.withdraw_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject.current_account).to receive(:cards) { fake_cards }
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.withdraw_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject.current_account).to receive(:cards) { fake_cards }
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.withdraw_money }.to output(/#{I18n.t('withdraw_money.wrong_number')}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.withdraw_money }.to output(/#{I18n.t('withdraw_money.wrong_number')}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { { number: 1, type: 'capitalist', balance: 50.0 } }
        let(:card_two) { { number: 2, type: 'capitalist', balance: 100.0 } }
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          current_subject.instance_variable_set(:@current_account, current_account)
          current_subject.current_account.instance_variable_set(:@cards, fake_cards)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect do
              current_subject.withdraw_money
            end.to output(/#{I18n.t('withdraw_money.prompt_input_amount')}/).to_stdout
          end
        end
      end
    end
  end
end
