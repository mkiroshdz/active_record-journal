RSpec.describe ActiveRecord::Journal do
  describe 'initialization' do
    subject { described_class.configuration }

    let(:journal) { ActiveRecord::Journal.configuration.journal }
    let(:allowed_on) { %w[reads writes] }
    let(:autorecording_enabled) { true }

    shared_examples 'has settings' do
      it { is_expected.not_to be nil }
      it { is_expected.to be_an_instance_of(described_class::Configuration) }
      it { expect(subject.journal).to eq journal }
      it { expect(subject.allowed_on).to eq allowed_on }
      it { expect(subject.autorecording_enabled).to eq autorecording_enabled }
    end

    context 'before init' do
      include_examples 'has settings'
    end

    context 'when journal_class_name set', init_params: { journal_class_name: 'CustomJournalRecord' } do
      let(:journal) { CustomJournalRecord }
      
      include_examples 'has settings'
    end

    context 'when allowed_on set', init_params: { allowed_on: %w[reads] } do
      let(:allowed_on) { %w[reads] }
      
      include_examples 'has settings'
    end

    context 'when autorecording_enabled set', init_params: { autorecording_enabled: false } do
      let(:autorecording_enabled) { false }
      
      include_examples 'has settings'
    end
  end
end
