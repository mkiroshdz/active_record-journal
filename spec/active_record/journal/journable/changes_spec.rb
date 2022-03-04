RSpec.describe ActiveRecord::Journal::Journable::Changes do
  describe '#call' do
    subject { described_class.new(record, action, keys).call }

    let(:book_model) do
      Class.new(ActiveRecord::Base) do
        self.table_name = :books
      end
    end

    let(:keys) { book_model.column_names }

    context 'when creating record' do
      let(:record) { book_model.create!(title: 'The Odyssey', resume: '  ') }
      let(:action) { 'create' }
      let(:changes) { { 'title' => [nil, 'The Odyssey'] } }

      it { is_expected.to match(hash_including(changes))  }
    end


    context 'when updating record' do
      let(:record) do 
        rec = book_model.create!(title: 'Odyssey', resume: 'Todo').reload
        rec.resume = nil
        rec.title = 'The Odyssey'
        rec
      end
      let(:action) { 'update' }
      let(:changes) { { 'title' => ['Odyssey', 'The Odyssey'], resume: ['Todo', nil] } }

      it { is_expected.to match(hash_including(changes))  }
    end

    context 'when destroying record' do
      let(:record) { book_model.create!(title: 'The Odyssey').reload }
      let(:action) { 'destroy' }
      let(:changes) { { 'id' =>  record.id, 'title' => 'The Odyssey'} }

      it { is_expected.to eq changes  }
    end

    context 'when reading record' do
      let(:record) { book_model.create!(title: 'The Odyssey').reload }
      let(:action) { 'read' }
      let(:changes) { {} }

      it { is_expected.to eq changes  }
    end
  end
end
