RSpec.describe ActiveRecord::Journal::Journable do
  let(:context) { klass.send(:journable_context) }
  
  describe 'rules setup' do
    let(:klass) { Fixtures::BookAuthor }
    let(:rules) { context.rules }

    it 'set correct read options' do
      expect(rules['read'].first.to_h).to eq({ 
        type: :reads, journable: klass, journal: CustomJournal,
        on: ActiveRecord::Journal::ACTIONS[:reads],
        if: :guest?, unless: nil, only: nil, except: nil
      })
    end

    it 'set correct create options' do
      expect(rules['create'].first.to_h).to eq({ 
        type: :writes, journable: klass, journal: Journal,
        on: %w[create], unless: :guest?, only: %w[book_id], 
        if: nil, except: nil
      })
    end

    it 'set correct update options' do
      expect(rules['update'].first.to_h).to eq({ 
        type: :writes, journable: klass, journal: Journal,
        on: %w[update], unless: nil, only: nil, 
        if: :guest?, except: %w[author_id]
      })
    end

    it 'set correct destroy options' do
      expect(rules['destroy'].first.to_h).to eq({ 
        type: :writes, journable: klass, journal: Journal,
        on: %w[destroy], unless: nil, only: [], 
        if: nil, except: nil
      })
    end
  end

  describe 'callbacks with read setup' do
    let(:klass) { Fixtures::GuestAuthor }

    context 'when write actions' do
      let(:record) { klass.create!(name: 'Homer', last_name: 'Simpson') }
      let(:journals) { record.journals }

      before do
        record.update!(last_name: 'Anon.')
        record.destroy!
      end
  
      it 'does not trigger write callbacks' do
        expect(journals.count).to eq 0
      end
    end

    context 'when read actions' do
      before do
        klass.create!(name: 'Homer', last_name: 'Simpson')
        klass.create!(name: 'Homer', last_name: 'Anon.')
      end

      it 'does not trigger write callbacks' do
        fst, scd, _ = klass.where(name: 'Homer').to_a
        expect(fst.journals.where(action: :read).count).to eq 1
        expect(scd.journals.where(action: :read).count).to eq 1
      end
    end
  end

  describe 'callbacks with write setup' do
    let(:klass) { Fixtures::OriginalAuthor }

    context 'when write actions' do
      let(:record) { klass.create!(name: 'Homer', last_name: 'Simpson') }
      let(:journals) { record.journals }

      before do
        record.update!(last_name: 'Anon.')
        record.destroy!
      end

      it 'does not trigger create callbacks' do
        expect(journals.where(action: :create).count).to eq 1
      end

      it 'does not trigger update callbacks' do
        expect(journals.where(action: :update).count).to eq 1
      end

      it 'does not trigger destroy callbacks' do
        expect(journals.where(action: :destroy).count).to eq 1
      end
    end

    context 'when read actions' do
      before do
        klass.create!(name: 'Homer', last_name: 'Simpson')
        klass.create!(name: 'Homer', last_name: 'Anon.')
      end

      it 'does not trigger write callbacks' do
        fst, scd, _ = klass.where(name: 'Homer').to_a
        expect(fst.journals.where(action: :read).count).to eq 0
        expect(scd.journals.where(action: :read).count).to eq 0
      end
    end
  end
end
