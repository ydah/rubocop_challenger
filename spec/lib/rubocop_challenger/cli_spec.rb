# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::CLI do
  let(:cli) { described_class.new }

  let(:options) do
    {
      email: 'rubocop-challenger@example.com',
      name: 'Rubocop Challenger',
      file_path: '.rubocop_todo.yml',
      mode: 'most_occurrence',
      base_branch: 'master',
      labels: ['rubocop challenge'],
      project_column_name: 'Column 1',
      project_id: 123_456_789,
      'no-create-pr': false,
      'exclude-limit': 99,
      'no-auto-gen-timestamp': true,
      verbose: false
    }
  end

  before do
    allow(cli).to receive(:options).and_return(options)
    allow(cli).to receive(:exit_process!)
  end

  describe '#go' do
    subject(:go) { cli.go }

    context 'without a exception' do
      let(:go_instance) { instance_double(RubocopChallenger::Go, exec: nil) }

      before do
        allow(RubocopChallenger::Go).to receive(:new).and_return(go_instance)
      end

      it 'calls RubocopChallenger::Go#exec' do
        go
        expect(RubocopChallenger::Go).to have_received(:new).with(options)
        expect(go_instance).to have_received(:exec)
      end
    end

    context 'with a exception' do
      before do
        allow(RubocopChallenger::Go).to receive(:new).and_raise('Error message')
      end

      it 'outputs a error message and exit process' do
        expect { go }.to output(/Error message/).to_stdout
        expect(cli).to have_received(:exit_process!)
      end
    end

    context 'when raise Errors::NoAutoCorrectableRule' do
      before do
        allow(RubocopChallenger::Go)
          .to receive(:new)
          .and_raise(RubocopChallenger::Errors::NoAutoCorrectableRule)
      end

      it 'outputs a description and exit process' do
        expect { go }.to output(/There is no auto-correctable rule/).to_stdout
      end

      it 'does not return exit code 1' do
        go
        expect(cli).not_to have_received(:exit_process!)
      end
    end
  end

  describe '#version' do
    it do
      expect { cli.version }
        .to output("#{RubocopChallenger::VERSION}\n").to_stdout
    end
  end

  describe '.exit_on_failure?' do
    subject { described_class.send(:exit_on_failure?) }

    it { is_expected.to be_truthy }
  end

  describe '#exit_process!' do
    subject(:exit_process!) { cli.send(:exit_process!) }

    before { allow(cli).to receive(:exit_process!).and_call_original }

    it { expect { exit_process! }.to raise_error(SystemExit) }
  end
end
