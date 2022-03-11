# frozen_string_literal: true

RSpec.describe 'conditioned tracking' do
  let(:journal_records) { configuration.entries_class }
  let(:configuration) { ActiveRecord::Journal.configuration }

  context 'when action is create' do
    let(:book_model) do
      Class.new(Fixtures::Anonymous) do
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

    it 'records records compliant actions' do
      expect(journal_records.where(journable: book1).count).to be 1
      expect(journal_records.where(journable: book2).count).to be 0
      expect(journal_records.where(journable: book3).count).to be 1
    end

    it 'tracks correct changes' do
      expect(journal_records.all[0].changes_map.keys).to eq %w[resume]
      expect(journal_records.all[1].changes_map.keys).to eq %w[title]
    end

    it 'records as create action' do
      expect(journal_records.all.map(&:action)).to all(eq 'create')
    end
  end

  describe 'when action is destroy' do
    let(:book_model) do
      Class.new(Fixtures::Anonymous) do
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

    it 'records only compliant actions' do
      expect(journal_records.where(journable: book1).count).to be 1
      expect(journal_records.where(journable: book2).count).to be 0
      expect(journal_records.where(journable: book3).count).to be 1
    end

    it 'tracks correct changes' do
      expect(journal_records.all[0].changes_map.keys).to eq %w[resume]
      expect(journal_records.all[1].changes_map.keys).to eq %w[title]
    end

    it 'records destroy action' do
      expect(journal_records.all.map(&:action)).to all(eq 'destroy')
    end
  end

  describe 'when action is update' do
    let(:book_model) do
      Class.new(Fixtures::Anonymous) do
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

    it 'records compliant actions' do
      expect(journal_records.where(journable: book1).count).to be 1
      expect(journal_records.where(journable: book2).count).to be 0
      expect(journal_records.where(journable: book3).count).to be 1
    end

    it 'tracks correct changes' do
      expect(journal_records.all[0].changes_map.keys).to eq %w[resume]
      expect(journal_records.all[1].changes_map.keys).to eq %w[title]
    end

    it 'records update action' do
      expect(journal_records.all.map(&:action)).to all(eq 'update')
    end
  end
end
