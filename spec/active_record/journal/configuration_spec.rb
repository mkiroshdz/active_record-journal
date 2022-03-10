# frozen_string_literal: true

RSpec.describe ActiveRecord::Journal::Configuration do
  subject { ActiveRecord::Journal.configuration }

  let(:entries_class) { ActiveRecord::Journal.configuration.entries_class }
  let(:tags_class) { ActiveRecord::Journal.configuration.tags_class }
  let(:autorecording_enabled) { true }

  shared_examples 'has settings' do
    it { is_expected.not_to be nil }

    it { is_expected.to be_an_instance_of(described_class) }

    it 'has entries_class' do
      expect(subject.entries_class).to eq entries_class
    end

    it 'has tags_class' do
      expect(subject.tags_class).to eq tags_class
    end

    it 'has autorecording_enabled' do
      expect(subject.autorecording_enabled).to eq autorecording_enabled
    end
  end

  context 'before init' do
    include_examples 'has settings'
  end

  context(
    'after init',
    entries_class: 'CustomJournalRecord',
    tags_class: 'CustomJournalTag',
    autorecording_enabled: false
  ) do
    let(:entries_class) { CustomJournalRecord }
    let(:tags_class) { CustomJournalTag }
    let(:autorecording_enabled) { false }

    include_examples 'has settings'
  end
end
