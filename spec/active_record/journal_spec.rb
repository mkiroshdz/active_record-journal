RSpec.describe ActiveRecord::Journal do
  it { binding.pry }

  describe '::VERSION' do
    subject { described_class::VERSION }

    it { is_expected.not_to be nil }
  end

  describe '::configuration' do
    subject { described_class.configuration }

    shared_examples 'has attributes' do
      it { expect(subject.journal).to eq journal }
    end

    context 'before init' do
      # let(:excluded_attributes) { %i[id primary_key inheritance_column locking_column] }
      let(:journal) { Journal }

      include_examples 'has attributes'
    end

    context 'after init' do
      let(:journal) { CustomJournal }

      include_examples 'has attributes'
    end
  end
end
