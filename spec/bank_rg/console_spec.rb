RSpec.describe BankRg::Console do
  let(:current_subject) { described_class }

  describe '#call' do
    context 'when correct method calling' do
      after do
        allow(current_subject).to receive(:main_menu)
        current_subject.call
      end

      it 'create account if input is create' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { I18n.t(:create, scope: :start_menu_commands) }
        expect(current_subject).to receive(:create)
      end

      it 'load account if input is load' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { I18n.t(:load, scope: :start_menu_commands) }
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
        expect(current_subject).to receive(:puts).with(I18n.t(:start_menu_phrases, **I18n.t(:start_menu_commands)))
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
        stub_const('OVERRIDABLE_FILENAME', 'spec/fixtures/account.yml')

        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*success_inputs)
        BankRg::AccountsManager.instance_variable_set(:@accounts, [])
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      it 'with correct out' do
        allow(File).to receive(:open)
        I18n.t(:ask_phrases).each_value { |phrase| expect(current_subject).to receive(:puts).with(phrase) }
        I18n.t(:account_validation_phrases).each_value.map(&:values).each do |phrase|
          expect(current_subject).not_to receive(:puts).with(phrase)
        end
        current_subject.create
      end

      it 'write to file Account instance' do
        stub_const('BankRg::AccountsManager::FILE_PATH', OVERRIDABLE_FILENAME)
        current_subject.create
        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a BankRg::Account }
      end
    end

    context 'with errors' do
      before do
        all_inputs = current_inputs + success_inputs
        allow(File).to receive(:open)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        BankRg::AccountsManager.instance_variable_set(:@accounts, [])
      end

      context 'with name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:error) { I18n.t('account_validation_phrases.name.first_letter') }
          let(:current_inputs) { [error_input, success_age_input, success_login_input, success_password_input] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with login errors' do
        let(:current_inputs) { [success_name_input, success_age_input, error_input, success_password_input] }

        context 'when present' do
          let(:error_input) { '' }
          let(:error) { I18n.t('account_validation_phrases.login.present') }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { I18n.t('account_validation_phrases.login.longer') }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { I18n.t('account_validation_phrases.login.shorter') }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when exists' do
          let(:error_input) { 'Denis1345' }
          let(:error) { I18n.t('account_validation_phrases.login.exists') }

          before do
            allow(BankRg::AccountsManager)
              .to receive(:accounts) { [instance_double('Account', login: error_input)] }
          end

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with age errors' do
        let(:current_inputs) { [success_name_input, error_input, success_login_input, success_password_input] }
        let(:error) { I18n.t('account_validation_phrases.age.length') }

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
          let(:error) { I18n.t('account_validation_phrases.password.present') }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { I18n.t('account_validation_phrases.password.longer') }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { I18n.t('account_validation_phrases.password.shorter') }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end
    end
  end

  describe '#load' do
    context 'without active accounts' do
      it do
        BankRg::AccountsManager.instance_variable_set(:@accounts, [])
        expect(current_subject).to receive(:create_the_first_account).and_return([])
        current_subject.load
      end
    end

    context 'with active accounts' do
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }

      before do
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(BankRg::AccountsManager)
          .to receive(:accounts) { [instance_double('Account', login: login, password: password)] }
      end

      context 'with correct out' do
        let(:all_inputs) { [login, password] }

        it do
          [I18n.t('ask_phrases.login'), I18n.t('ask_phrases.password')].each do |phrase|
            expect(current_subject).to receive(:puts).with(phrase)
          end
          current_subject.load
        end
      end

      context 'when account exists' do
        let(:all_inputs) { [login, password] }

        it do
          expect { current_subject.load }.not_to output(/#{I18n.t('error_phrases.user_not_exists')}/).to_stdout
        end
      end

      context 'when account doesn\t exists' do
        let(:all_inputs) { ['test', 'test', login, password] }

        it do
          expect { current_subject.load }.to output(/#{I18n.t('error_phrases.user_not_exists')}/).to_stdout
        end
      end
    end
  end

  describe '#create_the_first_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { I18n.t('y_n_answers.y') }

    it 'with correct out' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) {}
      expect(current_subject).to receive(:acquire_current_account)
      expect { current_subject.create_the_first_account }
        .to output(I18n.t('common_phrases.create_first_account', **I18n.t(:y_n_answers))).to_stdout
    end

    it 'calls create if user inputs is y' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
      expect(current_subject).to receive(:create)
      current_subject.create_the_first_account
    end

    it 'calls console if user inputs is not y' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }
      expect(current_subject).to receive(:acquire_current_account)
      current_subject.create_the_first_account
    end
  end

  describe '#main_menu' do
    let(:name) { 'John' }
    let(:commands) { I18n.t(:main_menu_commands) }

    context 'with correct out' do
      it do
        allow(current_subject).to receive(:show_cards)
        allow(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))
        expect { current_subject.main_menu }.to output(
          /#{I18n.t(:main_menu_phrases, **I18n.t(:main_menu_commands).merge(name: name))}/
        ).to_stdout
      end
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }

      it 'calls specific methods on predefined commands' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))
        allow(current_subject).to receive(:exit)

        commands.each do |method_name, command|
          expect(current_subject).to receive(method_name)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(command, 'exit')
          current_subject.main_menu
        end
      end

      it 'outputs incorrect message on undefined command' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', name: name))
        expect(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(undefined_command, 'exit')
        expect { current_subject.main_menu }.to output(/#{I18n.t('error_phrases.wrong_command')}/).to_stdout
      end
    end
  end

  describe '#destroy_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { I18n.t('y_n_answers.y') }
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }
    let(:correct_account) { instance_double('Account', login: correct_login) }
    let(:fake_account) { instance_double('Account', login: fake_login) }
    let(:fake_account2) { instance_double('Account', login: fake_login2) }
    let(:accounts) { [correct_account, fake_account, fake_account2] }

    before do
      stub_const('OVERRIDABLE_FILENAME', 'spec/fixtures/account.yml')
    end

    after do
      File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
    end

    it 'with correct out' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) {}
      expect { current_subject.destroy_account }
        .to output(I18n.t('common_phrases.destroy_account', **I18n.t(:y_n_answers))).to_stdout
    end

    context 'when deleting' do
      it 'deletes account if user inputs is y' do
        stub_const('BankRg::AccountsManager::FILE_PATH', OVERRIDABLE_FILENAME)
        expect(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
        expect(BankRg::AccountsManager).to receive(:accounts) { accounts }
        current_subject.instance_variable_set(:@current_account, instance_double('Account', login: correct_login))
        allow(current_subject).to receive(:exit)

        current_subject.destroy_account

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(file_accounts).to be_a Array
        expect(file_accounts.size).to be 2
      end

      it 'doesnt delete account' do
        expect(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }

        current_subject.destroy_account

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be false
      end
    end
  end

  describe '#show_cards' do
    let(:cards) do
      [
        instance_double('Card', number: 1234, type: 'a'),
        instance_double('Card', number: 5678, type: 'b')
      ]
    end

    it 'display cards if there are any' do
      current_subject.instance_variable_set(:@current_account, instance_double('Account', card: cards))
      cards.each { |card| expect(current_subject).to receive(:puts).with("- #{card.number}, #{card.type}") }
      current_subject.show_cards
    end

    it 'outputs error if there are no active cards' do
      current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
      expect(current_subject).to receive(:puts).with(I18n.t('error_phrases.no_active_cards'))
      current_subject.show_cards
    end
  end

  describe '#create_card' do
    context 'with correct out' do
      it do
        expect(current_subject).to receive(:puts)
          .with(I18n.t(:create_card_phrases, **I18n.t(:create_card_commands).merge(exit: I18n.t(:exit))))
        current_account = instance_double(BankRg::Account)
        allow(current_account).to receive(:create_card)
        allow(BankRg::AccountsManager).to receive(:update_accounts).with(current_account)
        current_subject.instance_variable_set(:@current_account, current_account)
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'usual' }

        current_subject.create_card
      end
    end

    context 'when correct card choose' do
      before do
        stub_const('OVERRIDABLE_FILENAME', 'spec/fixtures/account.yml')

        stub_const('BankRg::AccountsManager::FILE_PATH', OVERRIDABLE_FILENAME)
        current_account = BankRg::Account.new(login: 'test', name: 'Test', age: 33, password: 'test123')
        allow(BankRg::AccountsManager).to receive(:accounts) { [current_account] }
        current_subject.instance_variable_set(:@current_account, current_account)
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      {
        usual: {
          type: I18n.t('create_card_commands.usual'),
          balance: 50.00
        },
        capitalist: {
          type: I18n.t('create_card_commands.capitalist'),
          balance: 100.00
        },
        virtual: {
          type: I18n.t('create_card_commands.virtual'),
          balance: 150.00
        }
      }.each do |card_type, card_info|
        it "create card with #{card_type} type" do
          expect(current_subject).to receive_message_chain(:gets, :chomp) { card_info[:type] }

          current_subject.create_card

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.card.first.type).to eq card_info[:type]
          expect(file_accounts.first.card.first.balance).to eq card_info[:balance]
          expect(file_accounts.first.card.first.number.length).to be 16
        end
      end
    end

    context 'when incorrect card choose' do
      it do
        current_account = instance_double(BankRg::Account)
        allow(current_account).to receive(:create_card)
        allow(BankRg::AccountsManager).to receive(:update_accounts).with(current_account)
        current_subject.instance_variable_set(:@current_account, current_account)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')

        expect { current_subject.create_card }.to output(/#{I18n.t('error_phrases.wrong_card_type')}/).to_stdout
      end
    end
  end

  describe '#destroy_card' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
        expect { current_subject.destroy_card }.to output(/#{I18n.t('error_phrases.no_active_cards')}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { instance_double(BankRg::Card::BaseCard, number: 1, type: 'test') }
      let(:card_two) { instance_double(BankRg::Card::BaseCard, number: 2, type: 'test2') }
      let(:fake_cards) { [card_one, card_two] }
      let(:current_account) { BankRg::Account.new(login: 'test', name: 'Test', age: 33, password: 'test123') }

      before do
        current_account.instance_variable_set(:@card, fake_cards)
        current_subject.instance_variable_set(:@current_account, current_account)
      end

      context 'with correct out' do
        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.destroy_card }
            .to output(/#{I18n.t('common_phrases.if_you_want_to_delete')}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.destroy_card }.to output(message).to_stdout
          end
          current_subject.destroy_card
        end
      end

      context 'when exit if first gets is exit' do
        it do
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.destroy_card
        end
      end

      context 'with incorrect input of card number' do
        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.destroy_card }.to output(/#{I18n.t('error_phrases.wrong_number')}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.destroy_card }.to output(/#{I18n.t('error_phrases.wrong_number')}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:accept_for_deleting) { I18n.t('y_n_answers.y') }
        let(:reject_for_deleting) { 'asdf' }
        let(:deletable_card_number) { '1' }

        before do
          stub_const('OVERRIDABLE_FILENAME', 'spec/fixtures/account.yml')
          stub_const('BankRg::AccountsManager::FILE_PATH', OVERRIDABLE_FILENAME)

          allow(BankRg::AccountsManager).to receive(:accounts) { [current_account] }
        end

        after do
          File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
        end

        it 'accept deleting' do
          commands = [deletable_card_number, accept_for_deleting]
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { current_subject.destroy_card }.to change { current_account.card.size }.by(-1)

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.card).not_to include(card_one)
        end

        it 'decline deleting' do
          commands = [deletable_card_number, reject_for_deleting]
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)

          expect { current_subject.destroy_card }.not_to change(current_account.card, :size)
        end
      end
    end
  end

  describe '#put_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
        expect { current_subject.put_money }.to output(/#{I18n.t('error_phrases.no_active_cards')}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { instance_double(BankRg::Card::BaseCard, number: 1, type: 'test') }
      let(:card_two) { instance_double(BankRg::Card::BaseCard, number: 2, type: 'test2') }
      let(:fake_cards) { [card_one, card_two] }
      let(:current_account) { BankRg::Account.new(login: 'test', name: 'Test', age: 33, password: 'test123') }

      before do
        current_account.instance_variable_set(:@card, fake_cards)
        current_subject.instance_variable_set(:@current_account, current_account)
      end

      context 'with correct out' do
        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.put_money }.to output(/#{I18n.t('common_phrases.choose_card_putting')}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.put_money }.to output(message).to_stdout
          end
          current_subject.put_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.put_money
        end
      end

      context 'with incorrect input of card number' do
        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.put_money }.to output(/#{I18n.t('error_phrases.wrong_number')}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.put_money }.to output(/#{I18n.t('error_phrases.wrong_number')}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) do
          card = BankRg::Card::CapitalistCard.new current_account
          card.instance_variable_set(:@balance, 50)
          card
        end
        let(:card_two) do
          card = BankRg::Card::CapitalistCard.new current_account
          card.instance_variable_set(:@balance, 100)
          card
        end
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { '1' }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:correct_money_amount_greater_than_tax) { 50 }

        before do
          current_account.instance_variable_set(:@card, fake_cards)
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
          BankRg::AccountsManager.instance_variable_set(:@accounts, [current_account])
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.put_money }.to output(/#{I18n.t('common_phrases.put_amount')}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.put_money }.to output(/#{I18n.t('error_phrases.wrong_amount')}/).to_stdout
          end
        end

        context 'with tax greater than amount' do
          let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

          it do
            expect { current_subject.put_money }.to output(/#{I18n.t('error_phrases.tax_higher')}/).to_stdout
          end
        end

        context 'with tax lower than amount' do
          let(:custom_cards) do
            usual_card = BankRg::Card::UsualCard.new current_account
            usual_card.instance_variable_set(:@balance, default_balance)
            capitalist_card = BankRg::Card::CapitalistCard.new current_account
            capitalist_card.instance_variable_set(:@balance, default_balance)
            virtual_card = BankRg::Card::VirtualCard.new current_account
            virtual_card.instance_variable_set(:@balance, default_balance)
            [
              { card: usual_card, tax: correct_money_amount_greater_than_tax * 0.02, number: 1 },
              { card: capitalist_card, tax: 10, number: 1 },
              { card: virtual_card, tax: 1, number: 1 }
            ]
          end

          let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

          before do
            stub_const('OVERRIDABLE_FILENAME', 'spec/fixtures/account.yml')
            stub_const('BankRg::AccountsManager::FILE_PATH', OVERRIDABLE_FILENAME)

            allow(BankRg::AccountsManager).to receive(:accounts) { [current_account] }
            current_subject.instance_variable_set(:@current_account, current_account)
          end

          after do
            File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
          end

          # rubocop:disable RSpec/ExampleLength
          it do
            custom_cards.each do |custom_card|
              allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
              current_account.instance_variable_set(:@card, [custom_card[:card], card_one, card_two])

              new_balance = default_balance + correct_money_amount_greater_than_tax - custom_card[:tax]

              expect { current_subject.put_money }
                .to output(/#{I18n.t('common_phrases.money_was_put', **{
                                       amount: correct_money_amount_greater_than_tax,
                                       number: custom_card[:card].number,
                                       balance: new_balance,
                                       tax: custom_card[:tax]
                                     })}/).to_stdout

              expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
              file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
              expect(file_accounts.first.card.first.balance).to eq(new_balance)
            end
          end
          # rubocop:enable RSpec/ExampleLength
        end
      end
    end
  end

  describe '#withdraw_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
        expect { current_subject.withdraw_money }.to output(/#{I18n.t('error_phrases.no_active_cards')}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { instance_double(BankRg::Card::BaseCard, number: 1, type: 'test') }
      let(:card_two) { instance_double(BankRg::Card::BaseCard, number: 2, type: 'test2') }
      let(:fake_cards) { [card_one, card_two] }
      let(:current_account) { BankRg::Account.new(login: 'test', name: 'Test', age: 33, password: 'test123') }

      before do
        current_account.instance_variable_set(:@card, fake_cards)
        current_subject.instance_variable_set(:@current_account, current_account)
      end

      context 'with correct out' do
        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.withdraw_money }
            .to output(/#{I18n.t('common_phrases.choose_card_withdrawing')}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.withdraw_money }.to output(message).to_stdout
          end
          current_subject.withdraw_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.withdraw_money
        end
      end

      context 'with incorrect input of card number' do
        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.withdraw_money }.to output(/#{I18n.t('error_phrases.wrong_number')}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.withdraw_money }.to output(/#{I18n.t('error_phrases.wrong_number')}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) do
          card = BankRg::Card::CapitalistCard.new current_account
          card.instance_variable_set(:@balance, 50)
          card
        end
        let(:card_two) do
          card = BankRg::Card::CapitalistCard.new current_account
          card.instance_variable_set(:@balance, 100)
          card
        end
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { '1' }
        let(:incorrect_money_amount) { -2 }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { 50 }
        let(:correct_money_amount_greater_than_tax) { 5 }

        before do
          current_account.instance_variable_set(:@card, fake_cards)
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
          allow(BankRg::AccountsManager).to receive(:accounts) { [current_account] }
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.withdraw_money }.to output(/#{I18n.t('common_phrases.withdraw_amount')}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.withdraw_money }.to output(/#{I18n.t('error_phrases.wrong_amount')}/).to_stdout
          end
        end

        context 'with tax greater than amount' do
          let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

          it do
            expect { current_subject.withdraw_money }
              .to output(/#{I18n.t('error_phrases.not_enough_money_to_withdraw')}/).to_stdout
          end
        end

        context 'with tax lower than amount' do
          let(:custom_cards) do
            usual_card = BankRg::Card::UsualCard.new current_account
            usual_card.instance_variable_set(:@balance, default_balance)
            capitalist_card = BankRg::Card::CapitalistCard.new current_account
            capitalist_card.instance_variable_set(:@balance, default_balance)
            virtual_card = BankRg::Card::VirtualCard.new current_account
            virtual_card.instance_variable_set(:@balance, default_balance)
            [
              { card: usual_card, tax: correct_money_amount_greater_than_tax * 0.05, number: 1 },
              { card: capitalist_card, tax: correct_money_amount_greater_than_tax * 0.04, number: 1 },
              { card: virtual_card, tax: correct_money_amount_greater_than_tax * 0.88, number: 1 }
            ]
          end

          let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

          before do
            stub_const('OVERRIDABLE_FILENAME', 'spec/fixtures/account.yml')
            stub_const('BankRg::AccountsManager::FILE_PATH', OVERRIDABLE_FILENAME)

            allow(BankRg::AccountsManager).to receive(:accounts) { [current_account] }
            current_subject.instance_variable_set(:@current_account, current_account)
          end

          after do
            File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
          end

          # rubocop:disable RSpec/ExampleLength
          it do
            custom_cards.each do |custom_card|
              allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
              current_account.instance_variable_set(:@card, [custom_card[:card], card_one, card_two])

              new_balance = default_balance - correct_money_amount_greater_than_tax - custom_card[:tax]

              expect { current_subject.withdraw_money }
                .to output(/#{I18n.t('common_phrases.money_was_withdraw', **{
                                       amount: correct_money_amount_greater_than_tax,
                                       number: custom_card[:card].number,
                                       balance: new_balance,
                                       tax: custom_card[:tax]
                                     })}/).to_stdout

              expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
              file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
              expect(file_accounts.first.card.first.balance).to eq(new_balance)
            end
          end
          # rubocop:enable RSpec/ExampleLength
        end
      end
    end
  end

  describe '#send_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double('Account', card: []))
        expect { current_subject.send_money }.to output(/#{I18n.t('error_phrases.no_active_cards')}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { instance_double(BankRg::Card::BaseCard, number: 1, type: 'test') }
      let(:card_two) { instance_double(BankRg::Card::BaseCard, number: 2, type: 'test2') }
      let(:fake_cards) { [card_one, card_two] }
      let(:current_account) { BankRg::Account.new(login: 'test', name: 'Test', age: 33, password: 'test123') }

      before do
        current_account.instance_variable_set(:@card, fake_cards)
        current_subject.instance_variable_set(:@current_account, current_account)
      end

      context 'with correct out' do
        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.send_money }
            .to output(/#{I18n.t('common_phrases.choose_card_sending')}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.send_money }.to output(message).to_stdout
          end
          current_subject.send_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.send_money
        end
      end

      context 'with incorrect input of card number' do
        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.send_money }.to output(/#{I18n.t('error_phrases.wrong_number')}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.send_money }.to output(/#{I18n.t('error_phrases.wrong_number')}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) do
          card = BankRg::Card::CapitalistCard.new current_account
          card.instance_variable_set(:@balance, 50)
          card
        end
        let(:card_two) do
          card = BankRg::Card::CapitalistCard.new current_account
          card.instance_variable_set(:@balance, 5)
          card
        end
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { '1' }
        let(:incorrect_money_amount) { '-2' }
        let(:incorrect_recipient_number) { '123123123' }
        let(:default_balance) { 100.0 }
        let(:correct_money_amount_greater_than_tax) { 50 }
        let(:correct_money_amount_lower_than_tax) { 5 }

        before do
          current_account.instance_variable_set(:@card, fake_cards)
          current_subject.instance_variable_set(:@current_account, current_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
          allow(BankRg::AccountsManager).to receive(:accounts) { [current_account] }
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_recipient_number] }

          it do
            expect { current_subject.send_money }
              .to output(/#{I18n.t('common_phrases.enter_recipient_card')}/).to_stdout
          end
        end

        context 'with wrong recipient number' do
          let(:commands) { [chosen_card_number, incorrect_recipient_number] }

          it do
            expect { current_subject.send_money }
              .to output(/#{I18n.t('error_phrases.wrong_card_number_length')}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, card_two.number, incorrect_money_amount] }

          it do
            expect { current_subject.send_money }.to output(/#{I18n.t('error_phrases.wrong_amount')}/).to_stdout
          end
        end

        context 'with send tax greater than amount' do
          let(:commands) { [chosen_card_number, card_two.number, correct_money_amount_greater_than_tax] }

          it do
            expect { current_subject.send_money }
              .to output(/#{I18n.t('error_phrases.not_enough_money_to_send')}/).to_stdout
          end
        end

        context 'with put tax lower than amount' do
          let(:commands) { [chosen_card_number, card_two.number, correct_money_amount_lower_than_tax] }

          it do
            expect { current_subject.send_money }
              .to output(/#{I18n.t('error_phrases.tax_higher')}/).to_stdout
          end
        end

        context 'with correct taxes' do
          let(:custom_cards) do
            usual_card = BankRg::Card::UsualCard.new current_account
            usual_card.instance_variable_set(:@balance, default_balance)
            capitalist_card = BankRg::Card::CapitalistCard.new current_account
            capitalist_card.instance_variable_set(:@balance, default_balance)
            virtual_card = BankRg::Card::VirtualCard.new current_account
            virtual_card.instance_variable_set(:@balance, default_balance)
            [
              { card: usual_card, tax: 20, number: 1 },
              { card: capitalist_card, tax: correct_money_amount_greater_than_tax * 0.1, number: 2 },
              { card: virtual_card, tax: 1, number: 3 }
            ]
          end

          let(:commands) { [chosen_card_number, card_one.number, correct_money_amount_greater_than_tax] }

          before do
            stub_const('OVERRIDABLE_FILENAME', 'spec/fixtures/account.yml')
            stub_const('BankRg::AccountsManager::FILE_PATH', OVERRIDABLE_FILENAME)

            allow(BankRg::AccountsManager).to receive(:accounts) { [current_account] }
            current_subject.instance_variable_set(:@current_account, current_account)
          end

          after do
            File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
          end

          # rubocop:disable RSpec/ExampleLength
          it do
            custom_cards.each do |custom_card|
              allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
              current_account.instance_variable_set(:@card, [custom_card[:card], card_one, card_two])

              new_balance = default_balance - correct_money_amount_greater_than_tax - custom_card[:tax]

              expect { current_subject.send_money }
                .to output(/#{I18n.t('common_phrases.money_was_sent', **{
                                       amount: correct_money_amount_greater_than_tax,
                                       number: custom_card[:card].number,
                                       balance: new_balance,
                                       tax: custom_card[:tax]
                                     })}/).to_stdout

              expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
              file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
              expect(file_accounts.first.card.first.balance).to eq(new_balance)
            end
          end
          # rubocop:enable RSpec/ExampleLength
        end
      end
    end
  end
end
