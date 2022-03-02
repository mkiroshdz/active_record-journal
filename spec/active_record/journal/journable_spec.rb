RSpec.describe ActiveRecord::Journal::Journable do
  let(:configuration) { ActiveRecord::Journal.configuration }
  let(:journal_records) { configuration.journal }

  describe 'STI override only reads' do
    let(:context) { klass.send(:journable_context) }
    let(:klass) { Fixtures::GuestAuthor }

    context 'when write actions' do
      let(:record) { klass.create!(name: 'Homer', last_name: 'Simpson') }
      let(:journal_records) { record.journal_records }

      before do
        record.update!(last_name: 'Anon.')
        record.destroy!
      end
  
      it 'does not trigger write callbacks' do
        expect(journal_records.count).to eq 0
      end
    end

    context 'when read actions' do
      before do
        klass.create!(name: 'Homer', last_name: 'Simpson')
        klass.create!(name: 'Homer', last_name: 'Anon.')
      end

      it 'trigger read callbacks' do
        fst, scd, _ = klass.where(name: 'Homer').to_a
        expect(fst.journal_records.where(action: :read).count).to eq 1
        expect(scd.journal_records.where(action: :read).count).to eq 1
      end
    end
  end

  describe 'STI inherited only writes' do
    let(:context) { klass.send(:journable_context) }
    let(:klass) { Fixtures::OriginalAuthor }

    context 'when write actions' do
      let(:record) { klass.create!(name: 'Homer', last_name: 'Simpson') }
      let(:journal_records) { record.journal_records }

      before do
        record.update!(last_name: 'Anon.')
        record.destroy!
      end

      it 'trigger create callbacks' do
        expect(journal_records.where(action: :create).count).to eq 1
      end

      it 'trigger update callbacks' do
        expect(journal_records.where(action: :update).count).to eq 1
      end

      it 'trigger destroy callbacks' do
        expect(journal_records.where(action: :destroy).count).to eq 1
      end
    end

    context 'when read actions' do
      before do
        klass.create!(name: 'Homer', last_name: 'Simpson')
        klass.create!(name: 'Homer', last_name: 'Anon.')
      end

      it 'does not trigger read callbacks' do
        fst, scd, _ = klass.where(name: 'Homer').to_a
        expect(fst.journal_records.where(action: :read).count).to eq 0
        expect(scd.journal_records.where(action: :read).count).to eq 0
      end
    end
  end

  describe 'only create conditioned' do
    let(:book_model) do
      Class.new(Anonymous) do
        self.table_name = :books
        journal_writes on: %i[create], except: %i[title], if: ->(rec) { rec.title.to_s.include?('translation') }
        journal_writes on: %i[create], only: %i[title], if: ->(rec) { rec.title.to_s.include?('edition') }
      end
    end
  
    let(:book1) { book_model.create!(title: 'Don Quixote. translation', resume: 'Adventure') }
    let(:book2) { book_model.create!(title: 'El canto del mio cid. translation') }
    let(:book3) { book_model.create!(title: 'Calculus I. Second edition') }
  
    before do
      book1.update!(title: 'Don Quixote de la Mancha')
      book2.destroy
      book3
    end
  
    describe 'conditions check' do
      it 'records only compliant records' do
        expect(journal_records.where(journable: book1).count).to be 1
        expect(journal_records.where(journable: book2).count).to be 0
        expect(journal_records.where(journable: book3).count).to be 1
      end
    end
  
    describe 'tracked changes' do
      it do
        expect(journal_records.all[0].changes_map.keys).to eq %w[resume]
        expect(journal_records.all[1].changes_map.keys).to eq %w[title]
      end
    end

    describe 'tracked actions' do
      it { expect(journal_records.all.map(&:action)).to all(eq 'create') }
    end
  end

  describe 'only destroy conditioned' do
    let(:book_model) do
      Class.new(Anonymous) do
        self.table_name = :books
        journal_writes on: %i[destroy], except: %i[title], if: ->(rec) { rec.title.to_s.include?('translation') }
        journal_writes on: %i[destroy], only: %i[title], if: ->(rec) { rec.title.to_s.include?('edition') }
      end
    end
  
    let!(:book1) { book_model.create!(title: 'Don Quixote. translation', resume: 'Adventure').reload }
    let!(:book2) { book_model.create!(title: 'El canto del mio cid. translation').reload }
    let!(:book3) { book_model.create!(title: 'Calculus I. Second edition').reload }
  
    before do
      book1.destroy!
      book2.destroy!
      book3.destroy!
    end
  
    describe 'conditions check' do
      it 'records only compliant records' do
        expect(journal_records.where(journable: book1).count).to be 1
        expect(journal_records.where(journable: book2).count).to be 0
        expect(journal_records.where(journable: book3).count).to be 1
      end
    end
  
    describe 'tracked changes' do
      it do
        expect(journal_records.all[0].changes_map.keys).to eq %w[resume]
        expect(journal_records.all[1].changes_map.keys).to eq %w[title]
      end
    end

    describe 'tracked actions' do
      it { expect(journal_records.all.map(&:action)).to all(eq 'destroy') }
    end
  end

  describe 'only update conditioned' do
    let(:book_model) do
      Class.new(Anonymous) do
        self.table_name = :books
        journal_writes on: %i[update], except: %i[title], if: ->(rec) { rec.title.to_s.include?('translation') }
        journal_writes on: %i[update], only: %i[title], if: ->(rec) { rec.title.to_s.include?('edition') }
      end
    end
  
    let!(:book1) { book_model.create!(title: 'Don Quixote').reload }
    let!(:book2) { book_model.create!(title: 'El canto del mio cid.').reload }
    let!(:book3) { book_model.create!(title: 'Calculus I').reload }
  
    before do
      book1.update!(resume: 'Adventure', title: 'El Quixote. translation')
      book2.update!(title: 'El canto del mio cid. translation')
      book3.update!(title: 'Calculus I. Second edition')
      book1.destroy!
      book3.destroy!
    end
  
    describe 'conditions check' do
      it 'records only compliant records' do
        expect(journal_records.where(journable: book1).count).to be 1
        expect(journal_records.where(journable: book2).count).to be 0
        expect(journal_records.where(journable: book3).count).to be 1
      end
    end
  
    describe 'tracked changes' do
      it do
        expect(journal_records.all[0].changes_map.keys).to eq %w[resume]
        expect(journal_records.all[1].changes_map.keys).to eq %w[title]
      end
    end

    describe 'tracked actions' do
      it { expect(journal_records.all.map(&:action)).to all(eq 'update') }
    end
  end

  describe 'From abstract journable' do
    let(:context) { klass.send(:journable_context) }
    let(:klass) { Fixtures::SelfPublisher }
    let(:record) { klass.create!(name: 'Cosme', author_id: 1).reload }

    before do
      record.update!(name: 'Fulanito')
      record.destroy!
    end

    it 'record for read' do
      expect(journal_records.where(action: :read).count).to eq 1
    end

    it 'record for create' do
      expect(journal_records.where(action: :create).count).to eq 1
    end

    it 'record for update' do
      expect(journal_records.where(action: :update).count).to eq 1
    end

    it 'record for destroy' do
      expect(journal_records.where(action: :destroy).count).to eq 1
    end

  end
end
