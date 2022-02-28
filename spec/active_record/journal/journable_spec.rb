RSpec.describe ActiveRecord::Journal::Journable do

  let(:context) { klass.send(:journable_context) }

  describe '::journal_reads' do
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

      it 'trigger read callbacks' do
        fst, scd, _ = klass.where(name: 'Homer').to_a
        expect(fst.journals.where(action: :read).count).to eq 1
        expect(scd.journals.where(action: :read).count).to eq 1
      end
    end
  end

  describe '::journal_writes' do
    let(:klass) { Fixtures::OriginalAuthor }

    context 'when write actions' do
      let(:record) { klass.create!(name: 'Homer', last_name: 'Simpson') }
      let(:journals) { record.journals }

      before do
        record.update!(last_name: 'Anon.')
        record.destroy!
      end

      it 'trigger create callbacks' do
        expect(journals.where(action: :create).count).to eq 1
      end

      it 'trigger update callbacks' do
        expect(journals.where(action: :update).count).to eq 1
      end

      it 'trigger destroy callbacks' do
        expect(journals.where(action: :destroy).count).to eq 1
      end
    end

    context 'when read actions' do
      before do
        klass.create!(name: 'Homer', last_name: 'Simpson')
        klass.create!(name: 'Homer', last_name: 'Anon.')
      end

      it 'does not trigger read callbacks' do
        fst, scd, _ = klass.where(name: 'Homer').to_a
        expect(fst.journals.where(action: :read).count).to eq 0
        expect(scd.journals.where(action: :read).count).to eq 0
      end
    end
  end
end
