# frozen_string_literal: true

RSpec.describe ActiveRecord::Journal::Journable::Attributes do
  subject { described_class.new(record, rule) }
  let(:record) { model.new }
  let(:ignored_keys) {  %w[id type lock_version created_at updated_at] }

  describe '#tracked_keys' do
    let(:model) { Fixtures::Author }
    let(:rule) { model.journable_context.rules.search_by(action: 'update').first }
    let(:tracked_keys) { subject.keys - ignored_keys }

    it 'returns correct attributes' do
      expect(subject.tracked_keys).to eq tracked_keys
    end
  end

  describe '#ignored_keys' do
    context 'when no attribute options provided' do
      let(:model) { Fixtures::Author }
      let(:rule) { model.journable_context.rules.search_by(action: 'update').first }

      it 'returns correct attributes' do
        expect(subject.ignored_keys).to eq ignored_keys
      end
    end

    context 'when only option provided' do
      let(:model) { Fixtures::BookAuthor }
      let(:rule) { model.journable_context.rules.search_by(action: 'create').first }
      let(:ignored_keys) { (subject.keys - rule.only) | subject.default_ignored_keys }

      it 'returns correct attributes' do
        expect(subject.ignored_keys).to eq ignored_keys
      end
    end

    context 'when except option provided' do
      let(:model) { Fixtures::BookAuthor }
      let(:rule) { model.journable_context.rules.search_by(action: 'update').first }
      let(:ignored_keys) { subject.ignored_keys | rule.except }

      it 'returns correct attributes' do
        expect(subject.ignored_keys).to eq ignored_keys
      end
    end
  end
end
