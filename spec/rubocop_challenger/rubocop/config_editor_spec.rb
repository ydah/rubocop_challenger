# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Rubocop::ConfigEditor do
  let(:config_editor) { described_class.new(file_path: file_path) }
  let(:file_path) { 'spec/fixtures/.rubocop_challenge.yml' }

  describe '#initialize' do
    context 'when exists the config file' do
      it 'load data from the config file' do
        expect(config_editor.data).to eq YAML.load_file(file_path)
      end
    end

    context 'when does not exists the config file' do
      let(:file_path) { 'spec/fixtures/.not_exists.yml' }

      it 'initializes data as blank hash' do
        expect(config_editor.data).to eq({})
      end
    end
  end

  describe '#add_ignore' do
    subject(:add_ignore) { config_editor.add_ignore(rule) }

    context 'when add a new rule' do
      let(:rule) { RubocopChallenger::Rubocop::Rule.new(<<~CONTENTS) }
        Style/StringLiteralsInInterpolation:
          Enabled: false
      CONTENTS

      it 'add to ignred rules' do
        expect { add_ignore }
          .to change { config_editor.ignored_rules.size }.by(1)
      end
    end

    context 'when add a duplicate rule' do
      let(:rule) { RubocopChallenger::Rubocop::Rule.new(<<~CONTENTS) }
        Style/Semicolon:
          Enabled: false
      CONTENTS

      it 'does not add the rule' do
        expect { add_ignore }
          .not_to(change { config_editor.ignored_rules.size })
      end
    end
  end
end
