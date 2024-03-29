# frozen_string_literal: true

RSpec.describe ActiveRecord::Journal::Journable::Rule do
  let(:options) { ActiveRecord::Journal::Journable::Options.new(**kwargs) }
  subject { described_class.new(Class.new(Fixtures::JournableAppRecord), options) }

  describe '#conditions_met?' do
    context 'when no conditions' do
      let(:kwargs) { { type: :reads } }
      it { expect(subject.conditions_met?(nil)).to be true }
    end

    context 'when if procedure' do
      let(:kwargs) { { type: :reads, if: ->(r) { !r.nil? } } }

      context 'when if evaluates to a falsey value' do
        it { expect(subject.conditions_met?(nil)).to be false }
      end

      context 'when if evaluates to a truthy value' do
        it { expect(subject.conditions_met?('something')).to be true }
      end
    end

    context 'when unless procedure' do
      let(:kwargs) { { type: :reads, unless: ->(r) { r.nil? } } }

      context 'when unless evaluates to a truthy value' do
        it { expect(subject.conditions_met?(nil)).to be false }
      end

      context 'when if evaluates to a false value' do
        it { expect(subject.conditions_met?('something')).to be true }
      end
    end

    context 'when if method' do
      subject do
        Fixtures::BookAuthor.journable_context.rules.search_by(action: 'update').first
      end

      let(:record_with_author) { Fixtures::BookAuthor.new(author_id: 1) }
      let(:record_without_author) { Fixtures::BookAuthor.new }

      context 'when if evaluates to a falsey value' do
        it { expect(subject.conditions_met?(record_without_author)).to be false }
      end

      context 'when if evaluates to a truthy value' do
        it { expect(subject.conditions_met?(record_with_author)).to be true }
      end
    end

    context 'when unless method' do
      subject do
        Fixtures::BookAuthor.journable_context.rules.search_by(action: 'create').first
      end

      let(:record_with_author) { Fixtures::BookAuthor.new(author_id: 1) }
      let(:record_without_author) { Fixtures::BookAuthor.new }

      context 'when unless evaluates to a truthy value' do
        it { expect(subject.conditions_met?(record_without_author)).to be false }
      end

      context 'when if evaluates to a false value' do
        it { expect(subject.conditions_met?(record_with_author)).to be true }
      end
    end
  end
end
