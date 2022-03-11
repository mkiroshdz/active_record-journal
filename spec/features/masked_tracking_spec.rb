# frozen_string_literal: true

RSpec.describe 'masked tracking' do
  let(:configuration) { ActiveRecord::Journal.configuration }
  let(:journal_records) { configuration.entries_class }

  describe 'does not record the masked values' do
    let(:book_model) do
      Class.new(Fixtures::Anonymous) do
        self.table_name = :books
        journal_writes mask: %i[isbn publisher_id]
      end
    end

    let!(:record) { book_model.create!(title: 'Don Quixote', isbn: '1234', publisher_id: 1).reload }
    let(:audit) { journal_records.where(journable: record).first }
    let(:changes) do
      {
        'title' => [nil, 'Don Quixote'],
        'isbn' => [nil, nil],
        'publisher_id' => [nil, nil]
      }
    end

    it 'tracks correct changes' do
      expect(audit.changes_map).to match(changes)
    end
  end
end
