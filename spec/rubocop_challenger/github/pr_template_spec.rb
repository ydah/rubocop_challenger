# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Github::PrTemplate do
  describe '#generate' do
    let(:pr_template) { described_class.new(rule) }

    let(:rule) { RubocopChallenger::Rubocop::Rule.new(<<~CONTENTS) }
      # Offense count: 2
      # Cop supports --auto-correct.
      Style/Alias:
        Enabled: false
    CONTENTS

    let(:expected_template) { <<~EXPECTED }
      # Rubocop challenge!

      [Style/Alias](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/Alias)

      ## Description

      > ### Overview
      >
      > This cop enforces the use of either `#alias` or `#alias_method`
      > depending on configuration.
      > It also flags uses of `alias :symbol` rather than `alias bareword`.
      >
      > ### Examples
      >
      > #### EnforcedStyle: prefer_alias (default)
      >
      > ```rb
      > # bad
      > alias_method :bar, :foo
      > alias :bar :foo
      >
      > # good
      > alias bar foo
      > ```
      >
      > #### EnforcedStyle: prefer_alias_method
      >
      > ```rb
      > # bad
      > alias :bar :foo
      > alias bar foo
      >
      > # good
      > alias_method :bar, :foo
      > ```

      Auto generated by [rubocop_challenger](https://github.com/ryz310/rubocop_challenger)
    EXPECTED

    it 'returns PR template which includes rubydoc link and description' do
      expect(pr_template.generate).to eq expected_template
    end
  end
end
