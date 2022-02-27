RSpec.describe ActiveRecord::Journal do
  describe 'initialization' do
    subject { described_class.configuration }

    shared_examples 'has settings' do
      it { is_expected.not_to be nil }
      it { is_expected.to be_an_instance_of(described_class::Configuration) }
      it { expect(subject.journal).to eq journal }
      it { expect(subject.journables).to eq journables }
      it { expect(subject.journables).to all(respond_to(:journal_reads)) }
      it { expect(subject.journables).to all(respond_to(:journal_writes)) }
    end

    context 'before init' do
      let(:journal) { Journal }
      let(:journables) { [ ActiveRecord::Base ] }

      include_examples 'has settings'
    end

    context 'after init' do
      let(:journal) { CustomJournal }
      let(:journables) { [ Fixtures::AppRecord ] }

      before do
        described_class.init do |c|
          c.journal_class_name = 'CustomJournal'
          c.journable_class_names = ['Fixtures::AppRecord']
        end
      end

      include_examples 'has settings'
    end
  end
end
