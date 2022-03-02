RSpec.describe ActiveRecord::Journal::Journable::Context do
  let(:context) { klass.send(:journable_context) }

  describe '#configured_for?' do
    context 'when everything allowed' do
      let(:klass) { Fixtures::BookAuthor }

      it { expect(context.configured_for?('read')).to eq true }
      it { expect(context.configured_for?('create')).to eq true }
      it { expect(context.configured_for?('update')).to eq true }
      it { expect(context.configured_for?('destroy')).to eq true }
    end

    context 'when reads allowed' do
      let(:klass) { Fixtures::GuestAuthor }

      it { expect(context.configured_for?('read')).to eq true }
      it { expect(context.configured_for?('create')).to eq false }
      it { expect(context.configured_for?('update')).to eq false }
      it { expect(context.configured_for?('destroy')).to eq false }
    end

    context 'when writes allowed' do
      let(:klass) { Fixtures::OriginalAuthor }

      it { expect(context.configured_for?('read')).to eq false }
      it { expect(context.configured_for?('create')).to eq true }
      it { expect(context.configured_for?('update')).to eq true }
      it { expect(context.configured_for?('destroy')).to eq true }
    end
  end

  describe '#rules_store' do
    let(:klass) { Fixtures::BookAuthor }
    let(:rules) { context.rules }

    it 'set correct read options' do
      expect(rules.search_by(action: 'read').first.to_h).to include(
        type: :reads, journal: CustomJournalRecord, on: ActiveRecord::Journal::ACTIONS[:reads], if: :guest?
      )
    end

    it 'set correct create options' do
      expect(rules.search_by(action: 'create').first.to_h).to include(
        type: :writes, journal: ActiveRecord::Journal.configuration.journal, on: %w[create], unless: :without_author?, only: %w[book_id]
      )
    end

    it 'set correct update options' do
      expect(rules.search_by(action: 'update').first.to_h).to include(
        type: :writes, journal: ActiveRecord::Journal.configuration.journal, on: %w[update], if: :with_author?, except: %w[author_id]
      )
    end

    it 'set correct destroy options' do
      expect(rules.search_by(action: 'destroy').first.to_h).to include(
        type: :writes, journal: ActiveRecord::Journal.configuration.journal, on: %w[destroy], only: []
      )
    end
  end
end
