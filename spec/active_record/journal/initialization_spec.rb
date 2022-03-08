# frozen_string_literal: true

RSpec.describe ActiveRecord::Journal do
  describe 'initialization' do
    subject { described_class.configuration }

    let(:entries_class) { ActiveRecord::Journal.configuration.entries_class }
    let(:tags_class) { ActiveRecord::Journal.configuration.tags_class }
    let(:autorecording_enabled) { true }

    shared_examples 'has settings' do
      it { is_expected.not_to be nil }
      it { is_expected.to be_an_instance_of(described_class::Configuration) }
      it { expect(subject.entries_class).to eq entries_class }
      it { expect(subject.tags_class).to eq tags_class }
      it { expect(subject.autorecording_enabled).to eq autorecording_enabled }
    end

    context 'before init' do
      include_examples 'has settings'
    end

    context 'when entries_class set', entries_class: 'CustomJournalRecord' do
      let(:entries_class) { CustomJournalRecord }

      include_examples 'has settings'
    end

    context 'when autorecording_enabled set', autorecording_enabled: false do
      let(:autorecording_enabled) { false }

      include_examples 'has settings'
    end
  end
end
