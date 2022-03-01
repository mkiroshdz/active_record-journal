RSpec.describe ActiveRecord::Journal::Journable do

  let(:context) { klass.send(:journable_context) }

  describe '::journal_reads' do
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

  describe '::journal_writes' do
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
end
