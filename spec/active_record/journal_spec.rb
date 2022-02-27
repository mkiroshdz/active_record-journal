RSpec.describe ActiveRecord::Journal do
  describe '::VERSION' do
    subject { described_class::VERSION }

    it { is_expected.not_to be nil }
  end

  describe 'initialization' do
    subject { described_class.configuration }

    shared_examples 'has settings' do
      it { is_expected.not_to be nil }
      it { is_expected.to be_an_instance_of(described_class::Configuration) }
      it { expect(subject.default_journal).to eq journal }
    end

    context 'before init' do
      let(:journal) { Journal }

      include_examples 'has settings'
    end

    context 'after init' do
      let(:journal) { Fixtures::CustomJournal }

      before do
        described_class.init do |c|
          c.default_journal_class_name = 'Fixtures::CustomJournal'
        end
      end

      include_examples 'has settings'
    end
  end
end
