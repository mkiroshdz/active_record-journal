# frozen_string_literal: true

RSpec.describe ActiveRecord::Journal::Journable::Changes do
  describe '#call' do
    subject { described_class.new(record, action, keys, mask_keys).call }

    let(:book_model) do
      Class.new(Fixtures::Anonymous) do
        self.table_name = :books
      end
    end

    let(:ignored_keys) { %w[id created_at updated_at] }
    let(:keys) { book_model.column_names.map(&:to_s) - ignored_keys }
    let(:mask_keys) { %w[publisher_id] }

    context 'when creating record' do
      let(:record) { book_model.create!(title: 'The Odyssey', resume: ' ' * 3, publisher_id: 1) }
      let(:action) { 'create' }
      let(:changes) { { 'title' => [nil, 'The Odyssey'], 'publisher_id' => [nil, nil] } }

      it 'returns only the attributes that changed' do
        is_expected.to match(changes)
      end
    end

    context 'when updating record' do
      let(:record) do
        rec = book_model.create!(title: 'Odyssey', resume: 'Todo').reload
        rec.resume = nil
        rec.title = 'The Odyssey'
        rec.publisher_id = 1
        rec
      end
      let(:action) { 'update' }
      let(:changes) do
        { 'title' => ['Odyssey', 'The Odyssey'], 'resume' => ['Todo', nil], 'publisher_id' => [nil, nil] }
      end

      it 'returns only the attributes that changed' do
        is_expected.to match(changes)
      end
    end

    context 'when destroying record' do
      let(:record) { book_model.create!(title: 'The Odyssey', publisher_id: 1).reload }
      let(:action) { 'destroy' }
      let(:changes) { { 'title' => 'The Odyssey', 'publisher_id' => nil } }

      it 'returns only the attributes that changed' do
        is_expected.to match(changes)
      end
    end

    context 'when reading record' do
      let(:record) { book_model.create!(title: 'The Odyssey').reload }
      let(:action) { 'read' }
      let(:changes) { {} }

      it 'returns empty map' do
        is_expected.to match(changes)
      end
    end
  end
end
