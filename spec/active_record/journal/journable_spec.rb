RSpec.describe ActiveRecord::Journal::Journable do
  context 'when class is not journable' do
    subject { Fixtures::AppRecord }

    it { is_expected.not_to respond_to(:journal_reads) }
    it { is_expected.not_to respond_to(:journal_writes) }
  end
  
  context 'when class is not journable' do
    subject { Fixtures::JournableAppRecord }

    it { is_expected.to respond_to(:journal_reads) }
    it { is_expected.to respond_to(:journal_writes) }
  end
end