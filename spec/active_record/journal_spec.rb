RSpec.describe ActiveRecord::Journal do
  let(:configuration) { ActiveRecord::Journal.configuration }
  let(:journal_records) { configuration.journal }
  let(:user) { Fixtures::User.create!(username: 'janedoe') }

  describe 'STI config overwriten with only reads' do
    let(:context) { klass.journable_context }
    let(:klass) { Fixtures::GuestAuthor }

    context 'when writing journable' do
      let(:record) { klass.create!(name: 'Homer') }
      let(:journal_records) { record.journal_records }

      before do
        record.update!(last_name: 'Anon.')
        record.destroy!
      end
  
      it 'does not record journal' do
        expect(journal_records.count).to eq 0
      end
    end

    context 'when reading journable' do
      let(:records) do 
        [klass.create!(name: 'Jane', last_name: 'Doe'), klass.create!(name: 'Jonh', last_name: 'Doe')]
      end
      let(:journal_records) { super().where(action: :read) }

      before do
        ActiveRecord::Journal.ignore do |c|
          c.actions { records.each(&:reload) }
        end
        records.each {|r| klass.find(r.id) }
      end

      it 'records journal' do
        expect(journal_records.count).to eq 2
      end
    end

    context 'when autorecording disabled', init_params: { autorecording_enabled: false } do
      let(:record) { klass.create!(name: 'Jane', last_name: 'Doe') }
      let(:journal_records) { super().where(action: :read) }

      before do
        2.times { record.reload }
        klass.find(record.id)
        ActiveRecord::Journal.tag(user: user, description: 'test') do |context|
          context.actions { record.reload }
        end
      end

      it 'records journal' do
        expect(journal_records.count).to eq 1
      end

      it 'creates tag' do
        tag = JournalTag.first
        expect(tag.user).to eq user
        expect(journal_records.where(journal_tag_id: tag.id).count).to eq 1
      end
    end

    context 'when config overwriten for block' do
      let(:author) { klass.create!(last_name: 'Austin') }

      before do
        ActiveRecord::Journal.tag(user: user, description: 'test') do |context|
          context.record_when(klass, :reads, if: ->(r) { r.last_name == 'Doe' })
          context.actions { author.reload }
        end
        author.reload
      end

      it 'records journal' do
        expect(journal_records.where(action: :read, journable: author).count).to eq 1
      end
    end
  end

  describe 'STI with config inherited with only writes' do
    let(:context) { klass.journable_context }
    let(:klass) { Fixtures::OriginalAuthor }

    context 'when writing journable' do
      let(:record) { klass.create!(last_name: 'Austin') }
      let(:journal_records) { configuration.journal.where(journable: record) }

      before do
        record.update!(last_name: 'Wrong')
        ActiveRecord::Journal.ignore do |c|
          c.actions do
            record.update!(last_name: 'Anon')
            record.update!(last_name: 'Anonymous')
          end
        end
        record.destroy!
      end

      it 'records create journal' do
        expect(journal_records.where(action: :create).count).to eq 1
      end

      it 'records update journal' do
        expect(journal_records.where(action: :update).count).to eq 1
      end

      it 'records destroy journal' do
        expect(journal_records.where(action: :destroy).count).to eq 1
      end
    end

    context 'when autorecording disabled', init_params: { autorecording_enabled: false } do
      let(:record) { klass.create!(last_name: 'Austin') }
      let(:record2) { klass.create!(last_name: 'King') }
      let(:journal_records) { configuration.journal }

      before do
        record.update!(name: 'Jane')
        ActiveRecord::Journal.tag(user: user) do |context|
          context.actions do 
            klass.create!(last_name: 'Smith')
            record.update!(name: 'Erick')
            record.destroy! 
          end
        end
        record2.destroy!
        record.destroy!
      end

      it 'records create journal' do
        expect(journal_records.where(action: :create).count).to eq 1
      end

      it 'records update journal' do
        expect(journal_records.where(action: :update).count).to eq 1
      end

      it 'records destroy journal' do
        expect(journal_records.where(action: :destroy).count).to eq 1
      end

      it 'creates tag' do
        tag = JournalTag.first
        expect(tag.user).to eq user
        expect(journal_records.where(journal_tag_id: tag.id).count).to eq 3
      end
    end

    context 'when config overwriten for block' do
      let(:record) { klass.create!(last_name: 'Austin') }
      let(:journal_records) { configuration.journal.where(journable: record) }

      before do
        ActiveRecord::Journal.tag(user: user, description: 'test') do |context|
          context.record_when(klass, :writes, on: %i[destroy], if: ->(_) { false })
          context.actions do
            record.update!(name: 'Jane')
            record.update!(name: 'Erick')
            record.destroy!
          end
        end
        klass.create!(last_name: 'Smith')
        record.destroy!
      end

      it 'records create journal' do
        expect(journal_records.where(action: :create).count).to eq 1
      end

      it 'records update journal' do
        expect(journal_records.where(action: :update).count).to eq 2
      end

      it 'records destroy journal' do
        expect(journal_records.where(action: :destroy).count).to eq 1
      end
    end

    context 'when read actions' do
      let(:journal_records) { configuration.journal.where(action: :read) }

      before do
        klass.create!(last_name: 'Garcia Marquez')
        klass.create!(last_name: 'Allende')
      end

      it 'does not trigger read callbacks' do
        expect(journal_records.count).to eq 0
      end
    end
  end

  describe 'config inherited from abstract model' do
    let(:context) { klass.journable_context }
    let(:klass) { Fixtures::SelfPublisher }
    let(:record) { klass.create!(name: 'Gustav', author_id: 1) }

    before do
      ActiveRecord::Journal.tag(description: 'Rename and destroy') do |c|
        c.actions do
          record.reload
        end
      end

      record.update!(name: 'Friederich')
      record.destroy!

      ActiveRecord::Journal.ignore do |c|
        c.actions { klass.create!(name: 'Karl', author_id: 1).reload.destroy }
      end
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

    it 'creates tag' do
      tag = JournalTag.first
      expect(tag.description).to eq 'Rename and destroy'
      expect(journal_records.where(journal_tag_id: tag.id).count).to eq 2
    end
  end

  describe 'config for create action conditioned' do
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
  
    describe 'conditions check' do
      it 'records only compliant records' do
        expect(journal_records.where(journable: book1).count).to be 1
        expect(journal_records.where(journable: book2).count).to be 0
        expect(journal_records.where(journable: book3).count).to be 1
      end
    end
  
    describe 'record changes' do
      it do
        expect(journal_records.all[0].changes_map.keys).to eq %w[resume]
        expect(journal_records.all[1].changes_map.keys).to eq %w[title]
      end
    end

    describe 'record actions' do
      it { expect(journal_records.all.map(&:action)).to all(eq 'create') }
    end
  end

  describe 'config for destroy action conditioned' do
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
  
    describe 'conditions check' do
      it 'records only compliant records' do
        expect(journal_records.where(journable: book1).count).to be 1
        expect(journal_records.where(journable: book2).count).to be 0
        expect(journal_records.where(journable: book3).count).to be 1
      end
    end
  
    describe 'record changes' do
      it do
        expect(journal_records.all[0].changes_map.keys).to eq %w[resume]
        expect(journal_records.all[1].changes_map.keys).to eq %w[title]
      end
    end

    describe 'record actions' do
      it { expect(journal_records.all.map(&:action)).to all(eq 'destroy') }
    end
  end

  describe 'config for update action conditioned' do
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
  
    describe 'conditions check' do
      it 'records only compliant records' do
        expect(journal_records.where(journable: book1).count).to be 1
        expect(journal_records.where(journable: book2).count).to be 0
        expect(journal_records.where(journable: book3).count).to be 1
      end
    end
  
    describe 'record changes' do
      it do
        expect(journal_records.all[0].changes_map.keys).to eq %w[resume]
        expect(journal_records.all[1].changes_map.keys).to eq %w[title]
      end
    end

    describe 'record actions' do
      it { expect(journal_records.all.map(&:action)).to all(eq 'update') }
    end
  end
end
