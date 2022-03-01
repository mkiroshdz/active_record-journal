RSpec.describe ActiveRecord::Journal::Journable::Rule do
  let(:options) { ActiveRecord::Journal::Journable::Options.new(**kwargs) }
  subject { described_class.new(options) }

  describe '#conditions_met?' do
    context 'when no conditions' do
      let(:kwargs) { { type: :reads } }

      it { expect(subject.conditions_met?(nil)).to be true }
    end

    context 'when if procedure' do
      let(:kwargs) { { type: :reads, if: ->(r) { !r.nil? } } }

      
      it { expect(subject.conditions_met?(nil)).to be false }
      it { expect(subject.conditions_met?('something')).to be true }
    end

    context 'when unless procedure' do
      let(:kwargs) { { type: :reads, unless: ->(r) { r.nil? } } }

      
      it { expect(subject.conditions_met?(nil)).to be false }
      it { expect(subject.conditions_met?('something')).to be true }
    end

    context 'when if method' do
      subject { Fixtures::BookAuthor.journable_context.rules['update'].first }
      
      let(:record_with_author) { Fixtures::BookAuthor.new(author_id: 1) }
      let(:record_without_author) { Fixtures::BookAuthor.new }

      it { expect(subject.conditions_met?(record_without_author)).to be false }
      it { expect(subject.conditions_met?(record_with_author)).to be true }
    end

    context 'when unless method' do
      subject { Fixtures::BookAuthor.journable_context.rules['create'].first }
      
      let(:record_with_author) { Fixtures::BookAuthor.new(author_id: 1) }
      let(:record_without_author) { Fixtures::BookAuthor.new }

      it { expect(subject.conditions_met?(record_without_author)).to be false }
      it { expect(subject.conditions_met?(record_with_author)).to be true }
    end
  end
end
  